# Beneficiary API

## Base URL

```http
/api/v1/beneficiaries
```

All requests require a JWT token:

```http
Authorization: Bearer <access-token>
```

The backend automatically identifies the connected client from the JWT.  
The frontend must not send `clientUserId`.

---

## Beneficiary Object

```json
{
  "id": 1,
  "beneficiaryName": "Mohamed Ali",
  "ribNumber": "12345678901234567897"
}
```

| Field | Type | Description |
|---|---|---|
| `id` | number | Beneficiary identifier |
| `beneficiaryName` | string | Beneficiary full name |
| `ribNumber` | string | Tunisian RIB containing exactly 20 digits |

---

## 1. Create Beneficiary

```http
POST /api/v1/beneficiaries
```

### Input

```json
{
  "beneficiaryName": "Mohamed Ali",
  "ribNumber": "12345678901234567897"
}
```

### Success Response

```http
201 Created
```

```json
{
  "id": 1,
  "beneficiaryName": "Mohamed Ali",
  "ribNumber": "12345678901234567897"
}
```

### Business Rules

- `beneficiaryName` is required.
- `ribNumber` is required.
- The RIB must contain 20 digits.
- The RIB key is validated using the T24 modulo 97 algorithm.
- The client cannot add one of their own bank accounts.
- The same client cannot add the same RIB twice.

---

## 2. Get All Beneficiaries

```http
GET /api/v1/beneficiaries
```

### Success Response

```http
200 OK
```

```json
[
  {
    "id": 2,
    "beneficiaryName": "Sami Ben Ali",
    "ribNumber": "98765432109876543210"
  },
  {
    "id": 1,
    "beneficiaryName": "Mohamed Ali",
    "ribNumber": "12345678901234567897"
  }
]
```

The backend returns only beneficiaries belonging to the connected client.

---

## 3. Get Beneficiary by ID

```http
GET /api/v1/beneficiaries/{beneficiaryId}
```

### Example

```http
GET /api/v1/beneficiaries/1
```

### Success Response

```http
200 OK
```

```json
{
  "id": 1,
  "beneficiaryName": "Mohamed Ali",
  "ribNumber": "12345678901234567897"
}
```

---

## 4. Update Beneficiary

```http
PUT /api/v1/beneficiaries/{beneficiaryId}
```

### Input

```json
{
  "beneficiaryName": "Mohamed Ali Updated",
  "ribNumber": "12345678901234567897"
}
```

### Success Response

```http
200 OK
```

```json
{
  "id": 1,
  "beneficiaryName": "Mohamed Ali Updated",
  "ribNumber": "12345678901234567897"
}
```

The same validation rules used during creation are also applied during update.

---

## 5. Delete Beneficiary

```http
DELETE /api/v1/beneficiaries/{beneficiaryId}
```

### Example

```http
DELETE /api/v1/beneficiaries/1
```

### Success Response

```http
204 No Content
```

---

## Validation Errors

Possible business error codes:

| Error Code | Description |
|---|---|
| `INVALID_RIB` | The RIB format or key is invalid |
| `RIB_ALREADY_EXISTS` | The client already added this RIB |
| `SELF_BENEFICIARY_NOT_ALLOWED` | The RIB belongs to the connected client |
| `BENEFICIARY_NOT_FOUND` | The beneficiary does not exist or does not belong to the connected client |
| `AUTHENTICATED_CLIENT_NOT_FOUND` | The authenticated client was not found |

Example error response:

```json
{
  "success": false,
  "message": "RIB already exists.",
  "errorCode": "RIB_ALREADY_EXISTS"
}
```

---

## Angular Model

```typescript
export interface Beneficiary {
  id: number;
  beneficiaryName: string;
  ribNumber: string;
}

export interface BeneficiaryRequest {
  beneficiaryName: string;
  ribNumber: string;
}
```

## Angular Endpoints Summary

```typescript
POST   /api/v1/beneficiaries
GET    /api/v1/beneficiaries
GET    /api/v1/beneficiaries/{id}
PUT    /api/v1/beneficiaries/{id}
DELETE /api/v1/beneficiaries/{id}