# Accounts API — Angular Handoff

## Overview

The accounts module exposes two authenticated APIs:

1. List the authenticated customer’s accounts.
2. Get transactions for one account owned by the authenticated customer.

Base URL:

```http
/api/v1/accounts
```

All requests require:

```http
Authorization: Bearer <access-token>
```

The backend identifies the customer from the JWT. Angular must never send a T24 customer ID or another user ID.

---

## 1. List Customer Accounts

### Endpoint

```http
GET /api/v1/accounts
```

### Success response

```http
200 OK
```

```json
{
  "success": true,
  "message": "Customer accounts fetched successfully.",
  "data": [
    {
      "accountId": "1089021249356",
      "arrangementId": "AA26086WN1AX",
      "productName": "COMPTE PERSONNE",
      "iban": "TN5926028000890212493554",
      "currencyId": "TND",
      "availableBalance": 48731.000,
      "workingBalance": 48731.000
    }
  ],
  "timestamp": "2026-07-27T10:15:30.123456Z"
}
```

### Response fields

| Field | Type | Nullable | Description |
|---|---|---:|---|
| `accountId` | string | No | T24 account identifier |
| `arrangementId` | string | Yes | T24 arrangement identifier |
| `productName` | string | No | Account product/display name |
| `iban` | string | No | Account IBAN |
| `currencyId` | string | No | Account currency, such as `TND` |
| `availableBalance` | number | Yes | Available account balance |
| `workingBalance` | number | Yes | Working balance used by the backend’s transfer validation |

### Data source and fallback behavior

The backend uses this order:

```text
1. Read fresh accounts from Redis.
2. On cache miss, call T24.
3. On T24 success, update the database and two-minute Redis cache.
4. On T24 failure, return previously saved database accounts.
5. If no database accounts exist, return T24_ACCOUNTS_FETCH_FAILED.
```

Database fallback accounts may be stale. They are not written back into Redis, allowing the next request to retry T24 immediately. The current response contract does not indicate whether data came from T24, Redis, or the database.

---

## 2. Get Account Transactions

### Endpoint

```http
GET /api/v1/accounts/{iban}/transactions
```

Example:

```http
GET /api/v1/accounts/TN5926028000890212493554/transactions?fromDate=2026-01-12&toDate=2026-12-12&pageSize=50&pageStart=0
```

The backend verifies that the requested IBAN belongs to the authenticated customer before calling T24.

### Path parameter

| Parameter | Required | Description |
|---|---:|---|
| `iban` | Yes | IBAN of an account owned by the authenticated customer |

Angular should URL-encode the IBAN using `encodeURIComponent` before placing it in the path.

### Query parameters

| Parameter | Type | Required | Validation | Description |
|---|---|---:|---|---|
| `fromDate` | string | Yes | ISO date `yyyy-MM-dd` | First transaction date, inclusive |
| `toDate` | string | Yes | ISO date `yyyy-MM-dd` | Last transaction date, inclusive |
| `pageSize` | number | No | `1` to `100` | Requested T24 page size |
| `pageStart` | number | No | Minimum `0` | Requested starting page/index |
| `pageToken` | string | No | Non-blank when supplied | Token returned by a previous T24 page |

`fromDate` must be before or equal to `toDate`.

Angular sends these values as query parameters to the BTL Digital API. Internally, the backend forwards `pageSize`, `pageStart`, and `pageToken` to T24 as the HTTP headers `page_size`, `page_start`, and `page_token`. Only `fromDate` and `toDate` remain T24 query parameters.

### Success response

```http
200 OK
```

```json
{
  "success": true,
  "message": "Account transactions fetched successfully.",
  "data": {
    "summary": {
      "startDate": "01 APR 2026",
      "endDate": "27 MAR 2026",
      "todayDate": "27 MAR 2026",
      "accountTitle": "COMPTE PERSONNEL",
      "accountType": "COMPTE PERSONNEL BMTN",
      "currency": "TND",
      "totalAmount": 48731.000,
      "totalCredits": 51000.000,
      "totalDebits": -2269.000,
      "street": "RADES BEN AROUS",
      "addressLine1": "Account holder address",
      "addressLine2": "Additional address line",
      "postCode": "2013"
    },
    "pagination": {
      "pageStart": 1,
      "pageSize": 99,
      "totalSize": 12,
      "pageToken": "202603273073647427.00,99"
    },
    "transactions": [
      {
        "accountId": "1089021249356",
        "transactionReference": "FT260866NR7C",
        "transactionCode": "Transfer Out",
        "bookingDate": "27 MAR 2026",
        "valueDate": "27 MAR 2026",
        "closingBalance": 48731.000,
        "debitAmount": 100.000,
        "creditAmount": null,
        "narratives": [
          "To Acc.No.- 1089021207513"
        ]
      }
    ]
  },
  "timestamp": "2026-07-27T10:15:30.123456Z"
}
```

### Transaction notes

- `debitAmount` is normally populated for outgoing transactions.
- `creditAmount` is normally populated for incoming transactions.
- Either amount can be `null`; Angular must not assume both exist.
- T24 statement dates are returned as display strings such as `27 MAR 2026`, not ISO dates.
- T24 comma-formatted amounts are converted by the backend into JSON numbers.
- `summary` can be `null` if T24 returns no header data.
- `transactions` and `narratives` are returned as empty arrays rather than `null`.

### Pagination flow

Use the pagination values returned by the backend. T24 can return a `pageToken` even when the current response already contains all records, so the presence of a token alone does not mean another page exists.

Request another page only when the received transaction count and `totalSize` indicate that records remain. When another page is required, send the exact token returned for the same IBAN, date range, and page size:

```text
Initial request
  → fromDate + toDate + optional pageSize/pageStart
  → receive pagination.pageToken

Next request
  → same IBAN and date range
  → pageToken=<previous pagination.pageToken>
```

Do not invent or modify page tokens.

Page tokens are tied to a particular T24 enquiry. A token can be rejected when it is stale or reused with a different IBAN, date range, page size, or enquiry context. When `INVALID_PAGE_TOKEN` is returned, restart pagination without a token.

### Mandatory frontend token rules

The Angular implementation must follow all of these rules:

1. The first request must not contain `pageToken`.
2. Do not initialize `pageToken` with a placeholder, previously copied value, or token from local storage.
3. After a successful request, keep only the exact `response.data.pagination.pageToken` returned by that request.
4. Send that token only when requesting the immediately following page.
5. Keep the same IBAN, `fromDate`, `toDate`, and `pageSize` while using a token.
6. Reset the token and loaded transaction count whenever the IBAN, date range, or page size changes.
7. Never reuse a token after reloading the page, navigating away, logging out, or starting a new search.
8. Never alter, split, trim internally, decode, or manually URL-encode the token. `HttpParams` handles transport encoding.
9. A token containing punctuation such as `202603270748154320.01,20` is valid as an opaque string; the comma is part of the token.
10. Do not request another page merely because `pageToken` is non-null.

The reliable stop condition is:

```typescript
const hasNextPage = loadedTransactions.length < response.data.pagination.totalSize;
```

For example, when `totalSize` is `12` and the first response contains `12` transactions, pagination is complete even if T24 returned a token.

### Recommended Angular pagination state

```typescript
interface TransactionSearchState {
  iban: string;
  fromDate: string;
  toDate: string;
  pageSize: number;
  nextPageToken: string | null;
  transactions: AccountTransaction[];
  totalSize: number;
}

private state: TransactionSearchState = {
  iban: '',
  fromDate: '',
  toDate: '',
  pageSize: 20,
  nextPageToken: null,
  transactions: [],
  totalSize: 0
};
```

Start or restart a search:

```typescript
startTransactionSearch(
  iban: string,
  fromDate: string,
  toDate: string,
  pageSize = 20
): void {
  this.state = {
    iban,
    fromDate,
    toDate,
    pageSize,
    nextPageToken: null,
    transactions: [],
    totalSize: 0
  };

  this.loadNextTransactionPage();
}
```

Load the first or next page:

```typescript
loadNextTransactionPage(): void {
  if (
    this.state.transactions.length > 0 &&
    this.state.transactions.length >= this.state.totalSize
  ) {
    return;
  }

  const query: AccountTransactionQuery = {
    fromDate: this.state.fromDate,
    toDate: this.state.toDate,
    pageSize: this.state.pageSize
  };

  // The first request intentionally omits pageToken.
  if (this.state.nextPageToken) {
    query.pageToken = this.state.nextPageToken;
  }

  this.accountService
    .getTransactions(this.state.iban, query)
    .subscribe({
      next: response => {
        const page = response.data;

        this.state.transactions = [
          ...this.state.transactions,
          ...page.transactions
        ];
        this.state.totalSize = page.pagination.totalSize ?? 0;
        this.state.nextPageToken =
          this.state.transactions.length < this.state.totalSize
            ? page.pagination.pageToken
            : null;
      },
      error: error => {
        const apiError = error.error as ApiErrorResponse | undefined;

        if (apiError?.errorCode === 'INVALID_PAGE_TOKEN') {
          // Restart from page one; never retry the rejected token.
          this.startTransactionSearch(
            this.state.iban,
            this.state.fromDate,
            this.state.toDate,
            this.state.pageSize
          );
        }
      }
    });
}
```

The UI should disable or hide “Load more” when:

```typescript
state.transactions.length >= state.totalSize || !state.nextPageToken
```

---

## Common Response Models

```typescript
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

## Angular Account Models

```typescript
export interface CustomerAccount {
  accountId: string;
  arrangementId: string | null;
  productName: string;
  iban: string;
  currencyId: string;
  availableBalance: number | null;
  workingBalance: number | null;
}

export interface AccountTransactionsResponse {
  summary: AccountStatementSummary | null;
  pagination: AccountTransactionPagination;
  transactions: AccountTransaction[];
}

export interface AccountStatementSummary {
  startDate: string | null;
  endDate: string | null;
  todayDate: string | null;
  accountTitle: string | null;
  accountType: string | null;
  currency: string | null;
  totalAmount: number | null;
  totalCredits: number | null;
  totalDebits: number | null;
  street: string | null;
  addressLine1: string | null;
  addressLine2: string | null;
  postCode: string | null;
}

export interface AccountTransactionPagination {
  pageStart: number | null;
  pageSize: number | null;
  totalSize: number | null;
  pageToken: string | null;
}

export interface AccountTransaction {
  accountId: string;
  transactionReference: string;
  transactionCode: string;
  bookingDate: string;
  valueDate: string;
  closingBalance: number | null;
  debitAmount: number | null;
  creditAmount: number | null;
  narratives: string[];
}

export interface AccountTransactionQuery {
  fromDate: string;
  toDate: string;
  pageSize?: number;
  pageStart?: number;
  pageToken?: string;
}
```

---

## Angular Service

```typescript
import { inject, Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class AccountService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = '/api/v1/accounts';

  getAccounts(): Observable<ApiResponse<CustomerAccount[]>> {
    return this.http.get<ApiResponse<CustomerAccount[]>>(this.baseUrl);
  }

  getTransactions(
    iban: string,
    query: AccountTransactionQuery
  ): Observable<ApiResponse<AccountTransactionsResponse>> {
    let params = new HttpParams()
      .set('fromDate', query.fromDate)
      .set('toDate', query.toDate);

    if (query.pageSize !== undefined) {
      params = params.set('pageSize', query.pageSize);
    }
    if (query.pageStart !== undefined) {
      params = params.set('pageStart', query.pageStart);
    }
    if (query.pageToken) {
      params = params.set('pageToken', query.pageToken);
    }

    return this.http.get<ApiResponse<AccountTransactionsResponse>>(
      `${this.baseUrl}/${encodeURIComponent(iban)}/transactions`,
      { params }
    );
  }
}
```

Use the project’s JWT interceptor to add the `Authorization` header instead of adding it manually in this service.

---

## Error Codes

| Error code | Meaning | Suggested Angular behavior |
|---|---|---|
| `AUTHENTICATION_REQUIRED` | No authenticated principal exists | Clear the session and redirect to login |
| `T24_CUSTOMER_ID_MISSING` | Authenticated user is not linked to T24 | Show an account-linking/support error |
| `T24_ACCOUNTS_FETCH_FAILED` | T24 account listing failed and no DB fallback exists | Show a temporary unavailable state with retry |
| `INVALID_TRANSACTION_DATE_RANGE` | `fromDate` is after `toDate` | Display date-range validation feedback |
| `T24_ACCOUNT_TRANSACTIONS_FETCH_FAILED` | T24 transaction endpoint failed | Keep filters and allow retry |
| `INVALID_PAGE_TOKEN` | T24 rejected a stale or mismatched enquiry token | Restart from the first page without `pageToken` |
| `T24_ACCOUNT_TRANSACTIONS_INVALID_RESPONSE` | T24 returned an invalid monetary value | Show a temporary data error |
| `FORBIDDEN` | Requested IBAN is not owned by the authenticated customer | Do not expose the account; return to the account list |
| `CONSTRAINT_VIOLATION` | Pagination parameter is outside its allowed range | Display query validation feedback |
| `RATE_LIMIT_EXCEEDED` | Too many API requests | Respect `Retry-After` and delay retry |

Typical error response:

```json
{
  "success": false,
  "message": "Unable to fetch account transactions",
  "errorCode": "T24_ACCOUNT_TRANSACTIONS_FETCH_FAILED",
  "details": [],
  "timestamp": "2026-07-27T10:15:30.123456Z"
}
```

---

## Recommended Angular Flow

```text
1. Load GET /api/v1/accounts after authentication.
2. Display account cards/list using currency-aware number formatting.
3. When an account is selected, keep its IBAN and currency.
4. Ask the user for an ISO from/to date range.
5. Call GET /api/v1/accounts/{iban}/transactions.
6. Render statement summary and transactions.
7. Treat debit and credit amounts as nullable.
8. Use the returned page token for subsequent pages.
9. Handle 429 responses using Retry-After.
```
