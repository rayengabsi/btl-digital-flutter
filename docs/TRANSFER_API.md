# Intra Transfer API

## Base URLs

```http
/api/v1/transfers
/api/v1/transfer-demands
```

All requests require:

```http
Authorization: Bearer <access-token>
Content-Type: application/json
```

The transfer initiation and confirmation endpoints require the authority:

```text
MAKE_INTRA_TRANSFER
```

The transfer-demand history endpoints require authentication and automatically scope results to the authenticated user.

The transfer is processed in two steps:

```text
1. Initiate transfer
2. Confirm transfer using OTP
```

---

# 1. Initiate Intra Transfer

## Endpoint

```http
POST /api/v1/transfers/intra
```

This endpoint validates the transfer request, creates a pending transfer demand and sends a 6-digit OTP to the authenticated client.

## Request

```json
{
  "transactionType": "AC",
  "debitAccountId": "1089021249356",
  "debitCurrency": "TND",
  "debitAmount": 18,
  "creditAccountId": "1089021207513",
  "paymentDetails": [
    {
      "paymentDetail": "Transfer payment"
    }
  ]
}
```

## Request Fields

| Field | Type | Required | Description |
|---|---|---:|---|
| `transactionType` | string | Yes | T24 transaction type |
| `debitAccountId` | string | Yes | Account to debit |
| `debitCurrency` | string | Yes | Debit account currency |
| `debitAmount` | number | Yes | Transfer amount, minimum `0.001` |
| `creditAccountId` | string | Yes | Account to credit |
| `paymentDetails` | array | Yes | Transfer payment descriptions |
| `paymentDetails[].paymentDetail` | string | Yes | Payment description |

## Success Response

```http
200 OK
```

```json
{
  "success": true,
  "message": "Transfer OTP sent.",
  "data": {
    "transferDemandId": 15,
    "status": "PENDING",
    "otpExpiresAt": "2026-07-17T09:35:00Z"
  }
}
```

## Initiation Response Fields

| Field | Type | Description |
|---|---|---|
| `transferDemandId` | number | Identifier of the pending transfer |
| `status` | string | Current transfer demand status |
| `otpExpiresAt` | string | OTP expiration date in ISO-8601 format |

Angular must store `transferDemandId` because it is required during OTP confirmation.

---

# 2. Confirm Intra Transfer

## Endpoint

```http
POST /api/v1/transfers/intra/confirm
```

This endpoint verifies the OTP and sends the transfer order to T24.

## Request

```json
{
  "transferDemandId": 15,
  "otp": "123456"
}
```

## Request Fields

| Field | Type | Required | Description |
|---|---|---:|---|
| `transferDemandId` | number | Yes | ID returned by the initiation endpoint |
| `otp` | string | Yes | Exactly 6 numeric digits |

## Success Response

```http
200 OK
```

```json
{
  "success": true,
  "message": "Transfer order processed.",
  "data": {
    "transactionId": "FT2619900001",
    "status": "SUCCESS",
    "transactionStatus": "BOOKED",
    "transactionType": "AC",
    "debitAccountId": "1089021249356",
    "debitAccountIban": "TN59108902124935600000",
    "debitCurrency": "TND",
    "debitAmount": 18,
    "debitValueDate": "20260717",
    "creditAccountId": "1089021207513",
    "creditAccountIban": "TN59108902120751300000",
    "creditCurrencyId": "TND",
    "creditValueDate": "20260717",
    "commissionCode": "STANDARD",
    "profitCentreCustomer": "TN0010001",
    "paymentDetails": [
      {
        "paymentDetail": "Transfer payment"
      }
    ],
    "overrideDetails": []
  }
}
```

Actual values are returned by T24.

---

# 3. List Authenticated User's Transfer Demands

## Endpoint

```http
GET /api/v1/transfer-demands?page=0&size=20&from=2026-07-01&to=2026-07-21
```

This endpoint returns only transfer demands owned by the authenticated user. The frontend must not send a client user ID.

## Query Parameters

| Parameter | Required | Default | Description |
|---|---:|---:|---|
| `page` | No | `0` | Zero-based page number; negative values are treated as `0` |
| `size` | No | `20` | Page size; maximum value is `100` |
| `from` | No | None | Start date, inclusive, in `yyyy-MM-dd` format |
| `to` | No | None | End date, inclusive, in `yyyy-MM-dd` format |

When dates are supplied, day boundaries are calculated using the `Africa/Tunis` business timezone. `from` must be before or equal to `to`.

## Success Response

Unlike the transfer-order endpoints, this endpoint currently returns the page directly without an `ApiResponse` envelope.

```http
200 OK
```

```json
{
  "content": [
    {
      "id": 15,
      "clientUserId": 7,
      "amount": 18.000,
      "transactionType": "AC",
      "debitAccountId": "1089021249356",
      "debitCurrency": "TND",
      "creditAccountId": "1089021207513",
      "paymentDetails": ["Transfer payment"],
      "status": "SUCCESSFUL",
      "createdAt": "2026-07-17T09:30:00Z",
      "completedAt": "2026-07-17T09:32:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1,
  "first": true,
  "last": true
}
```

Results are sorted by `createdAt` descending and then `id` descending.

---

# 4. Get Authenticated User's Transfer Demand by ID

## Endpoint

```http
GET /api/v1/transfer-demands/{id}
```

Example:

```http
GET /api/v1/transfer-demands/15
```

The demand is returned only when it belongs to the authenticated user. A missing demand and a demand owned by another user both produce `TRANSFER_DEMAND_NOT_FOUND`, preventing ownership information from being exposed.

## Success Response

This endpoint also returns `TransferDemandResponse` directly without an `ApiResponse` envelope.

```http
200 OK
```

```json
{
  "id": 15,
  "clientUserId": 7,
  "amount": 18.000,
  "transactionType": "AC",
  "debitAccountId": "1089021249356",
  "debitCurrency": "TND",
  "creditAccountId": "1089021207513",
  "paymentDetails": ["Transfer payment"],
  "status": "SUCCESSFUL",
  "createdAt": "2026-07-17T09:30:00Z",
  "completedAt": "2026-07-17T09:32:00Z"
}
```

Possible status values are `PENDING`, `SUCCESSFUL`, and `FAILED`. `completedAt` is `null` while a demand is pending.

---

# Validation Errors

## Initiation

| Field | Error |
|---|---|
| `transactionType` | Transaction type is required |
| `debitAccountId` | Debit account ID is required |
| `debitCurrency` | Debit currency is required |
| `debitAmount` | Debit amount is required |
| `debitAmount` | Debit amount must be greater than zero |
| `creditAccountId` | Credit account ID is required |
| `paymentDetails` | Payment details are required |
| `paymentDetail` | Payment detail is required |

## Confirmation

| Field | Error |
|---|---|
| `transferDemandId` | Transfer demand ID is required |
| `otp` | OTP is required |
| `otp` | OTP must contain exactly 6 digits |

---

# Main Business Errors

| Error Code | Description |
|---|---|
| `AUTHENTICATION_REQUIRED` | No authenticated user was found |
| `T24_CUSTOMER_ID_MISSING` | User is not linked to a T24 customer |
| `INVALID_OTP` | OTP is incorrect |
| `OTP_EXPIRED` | OTP has expired |
| `TRANSFER_DEMAND_NOT_FOUND` | Demand does not exist or belongs to another user |
| `TRANSFER_ALREADY_PROCESSED` | Transfer was already confirmed or rejected |
| `403 FORBIDDEN` | User does not have `MAKE_INTRA_TRANSFER` |

---

# Angular Models

```typescript
export interface IntraTransferRequest {
  transactionType: string;
  debitAccountId: string;
  debitCurrency: string;
  debitAmount: number;
  creditAccountId: string;
  paymentDetails: PaymentDetailRequest[];
}

export interface PaymentDetailRequest {
  paymentDetail: string;
}

export interface IntraTransferInitiationResponse {
  transferDemandId: number;
  status: string;
  otpExpiresAt: string;
}

export interface ConfirmIntraTransferRequest {
  transferDemandId: number;
  otp: string;
}

export interface IntraTransferResponse {
  transactionId: string;
  status: string;
  transactionStatus: string;
  transactionType: string;
  debitAccountId: string;
  debitAccountIban: string;
  debitCurrency: string;
  debitAmount: number;
  debitValueDate: string;
  creditAccountId: string;
  creditAccountIban: string;
  creditCurrencyId: string;
  creditValueDate: string;
  commissionCode: string;
  profitCentreCustomer: string;
  paymentDetails: PaymentDetailResponse[];
  overrideDetails: OverrideDetailResponse[];
}

export type TransferDemandStatus = 'PENDING' | 'SUCCESSFUL' | 'FAILED';

export interface TransferDemandResponse {
  id: number;
  clientUserId: number;
  amount: number;
  transactionType: string;
  debitAccountId: string;
  debitCurrency: string;
  creditAccountId: string;
  paymentDetails: string[];
  status: TransferDemandStatus;
  createdAt: string;
  completedAt: string | null;
}

export interface PageResponse<T> {
  content: T[];
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
  first: boolean;
  last: boolean;
}

export interface PaymentDetailResponse {
  paymentDetail: string;
}

export interface OverrideDetailResponse {
  code: string;
  id: string;
  type: string;
  description: string;
  options: string[];
}

export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
}
```

---

# Angular Flow

```text
1. Display transfer form
2. POST /api/v1/transfers/intra
3. Store transferDemandId
4. Display OTP form
5. POST /api/v1/transfers/intra/confirm
6. Display final transfer result
```
