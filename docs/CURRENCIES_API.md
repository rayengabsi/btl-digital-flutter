# Currencies API — Angular Handoff

## Overview

The currencies endpoint receives currency/market pairs, fetches the T24 reference currencies once, and returns the corresponding buy and sell rates.

The endpoint requires an authenticated user. Angular must send the JWT access token through the existing authentication interceptor.

## Endpoint

```http
POST /api/v1/currencies/rates
Authorization: Bearer <access-token>
Content-Type: application/json
```

Although T24 exposes a `GET` endpoint internally, the frontend endpoint is `POST` because it accepts a structured list of currency/market pairs.

## Request

```json
{
  "currencies": [
    {
      "currencyId": "AED",
      "market": "10"
    },
    {
      "currencyId": "BHD",
      "market": "1"
    }
  ]
}
```

### Request fields

| Field | Type | Required | Description |
|---|---|---:|---|
| `currencies` | array | Yes | At least one currency/market pair |
| `currencies[].currencyId` | string | Yes | ISO-style currency ID, for example `AED` or `BHD` |
| `currencies[].market` | string | Yes | T24 market identifier, for example `1` or `10` |

Currency IDs are trimmed and normalized to uppercase by the backend. Market identifiers are strings and should not be converted to numbers by Angular.

## Success Response

```http
200 OK
```

```json
{
  "success": true,
  "message": "Currency markets fetched successfully.",
  "data": [
    {
      "currencyId": "AED",
      "displayName": "United Arab Emirates Dirhams",
      "sellMarket": 8.60,
      "buyMarket": 8.34
    },
    {
      "currencyId": "BHD",
      "displayName": "Bahraini Dinar",
      "sellMarket": 8.504,
      "buyMarket": 8.103
    }
  ],
  "timestamp": "2026-07-24T10:15:30.123456Z"
}
```

The response order matches the request order.

### Response fields

| Field | Type | Description |
|---|---|---|
| `currencyId` | string | Currency ID returned by T24 |
| `displayName` | string | Human-readable currency name |
| `sellMarket` | number | T24 `sellRate` for the requested market |
| `buyMarket` | number | T24 `buyRate` for the requested market |

## Angular Models

```typescript
export interface CurrencyMarketItem {
  currencyId: string;
  market: string;
}

export interface CurrencyMarketRequest {
  currencies: CurrencyMarketItem[];
}

export interface CurrencyMarketResponse {
  currencyId: string;
  displayName: string;
  sellMarket: number;
  buyMarket: number;
}

export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
  timestamp: string;
}

export interface ApiErrorResponse {
  success: false;
  message: string;
  errorCode: string;
  details: string[];
  timestamp: string;
}
```

## Angular Service

```typescript
import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class CurrencyService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = '/api/v1/currencies';

  getRates(
    currencies: CurrencyMarketItem[]
  ): Observable<ApiResponse<CurrencyMarketResponse[]>> {
    const request: CurrencyMarketRequest = { currencies };

    return this.http.post<ApiResponse<CurrencyMarketResponse[]>>(
      `${this.baseUrl}/rates`,
      request
    );
  }
}
```

If the Angular application uses an environment API URL, construct `baseUrl` from that value instead:

```typescript
private readonly baseUrl = `${environment.apiUrl}/api/v1/currencies`;
```

## Example Component Usage

```typescript
readonly loading = signal(false);
readonly rates = signal<CurrencyMarketResponse[]>([]);
readonly errorMessage = signal<string | null>(null);

loadRates(): void {
  const requestedCurrencies: CurrencyMarketItem[] = [
    { currencyId: 'AED', market: '10' },
    { currencyId: 'BHD', market: '1' }
  ];

  this.loading.set(true);
  this.errorMessage.set(null);

  this.currencyService.getRates(requestedCurrencies).subscribe({
    next: response => {
      this.rates.set(response.data);
      this.loading.set(false);
    },
    error: error => {
      const apiError = error.error as ApiErrorResponse | undefined;
      this.errorMessage.set(
        apiError?.message ?? 'Unable to load currency rates.'
      );
      this.loading.set(false);
    }
  });
}
```

## Example Template

```html
@if (loading()) {
  <p>Loading currency rates...</p>
} @else if (errorMessage()) {
  <p class="error">{{ errorMessage() }}</p>
} @else {
  <table>
    <thead>
      <tr>
        <th>Currency</th>
        <th>Name</th>
        <th>Buy</th>
        <th>Sell</th>
      </tr>
    </thead>
    <tbody>
      @for (rate of rates(); track $index) {
        <tr>
          <td>{{ rate.currencyId }}</td>
          <td>{{ rate.displayName }}</td>
          <td>{{ rate.buyMarket | number:'1.3-3' }}</td>
          <td>{{ rate.sellMarket | number:'1.3-3' }}</td>
        </tr>
      }
    </tbody>
  </table>
}
```

The example tracks by index because the same currency can be requested more than once with different markets, while the response contract does not include the market identifier.

## Validation and Business Errors

| Error code | Meaning | Suggested frontend behavior |
|---|---|---|
| `VALIDATION_ERROR` | Request list is empty or a field is blank | Display field/form validation messages from `details[]` |
| `AUTHENTICATION_REQUIRED` | No authenticated user is available | Clear authentication state and redirect to login |
| `CURRENCY_NOT_FOUND` | Requested currency does not exist in the T24 response | Show that the selected currency is unavailable |
| `CURRENCY_MARKET_NOT_FOUND` | Requested market does not exist for that currency | Ask the user to select another market |
| `T24_CURRENCIES_FETCH_FAILED` | T24 failed, returned an unsuccessful status, or returned invalid data | Show a temporary service-unavailable message and allow retry |

Typical error response:

```json
{
  "success": false,
  "message": "Market 99 not found for currency AED",
  "errorCode": "CURRENCY_MARKET_NOT_FOUND",
  "details": [],
  "timestamp": "2026-07-24T10:15:30.123456Z"
}
```

## Frontend Flow

```text
1. Build the list of required currency/market pairs.
2. Ensure both currencyId and market are non-blank.
3. POST the complete list to /api/v1/currencies/rates.
4. Read rates from response.data.
5. Display buyMarket and sellMarket using the desired decimal precision.
6. Handle unavailable pairs and temporary T24 failures using errorCode.
```
