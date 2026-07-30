# BTL Digital API Frontend Handoff

This document summarizes the current backend API contract for the Angular frontend.

## Base

- Base path: `/api/v1`
- Default local port: `8080`
- Main content type: `application/json`
- Public endpoints:
  - `POST /api/v1/registration/**`
  - `POST /api/v1/auth/login`
  - `POST /api/v1/auth/login/verify-otp`
  - `GET /actuator/health`
- JWT authenticated endpoints: any future endpoint not explicitly permitted by security config.
- Auth header for protected endpoints:

```http
Authorization: Bearer <accessToken>
```

## Common Success Envelope

All controller success responses use:

```json
{
  "success": true,
  "message": "Human readable message",
  "data": {},
  "timestamp": "2026-05-26T10:15:30.123456Z"
}
```

For endpoints returning no data, `data` is `null`.

## Common Error Envelope

Errors use:

```json
{
  "success": false,
  "message": "Human readable error",
  "errorCode": "ERROR_CODE",
  "details": [],
  "timestamp": "2026-05-26T10:15:30.123456Z"
}
```

Validation errors use:

```json
{
  "success": false,
  "message": "Validation failed",
  "errorCode": "VALIDATION_ERROR",
  "details": [
    "fieldName: validation message"
  ],
  "timestamp": "2026-05-26T10:15:30.123456Z"
}
```

Note: service-level business errors currently return HTTP `400`. Login bad credentials are also returned as `400 BAD_CREDENTIALS` by the current `AuthService`.

## Registration Flow

The frontend registration flow is:

1. Verify client and send phone OTP.
2. Verify phone OTP.
3. Submit email and send email verification code.
4. Verify email code.
5. Complete registration with password.
6. Login.

The `registrationSessionToken` returned by step 1 must be kept by the frontend and sent to every later registration step.

### 1. Verify Client

```http
POST /api/v1/registration/verify-client
```

Purpose:
- Verifies customer against T24 using ID type, ID number, date of birth, and phone number.
- The submitted phone number must match T24 `SMS_1` after digit normalization.
- Rejects clients already registered in `CLIENT_USER.T24_CUSTOMER_ID`.
- Creates a registration session.
- Sends a 6-digit phone OTP to the verified T24 phone number.

Request:

```json
{
  "firstName": "Amina",
  "lastName": "Ben Ali",
  "idType": "CIN",
  "idNumber": "12345678",
  "dateOfBirth": "19900101",
  "phoneNumber": "21655123456"
}
```

Fields:

| Field | Required | Validation | Notes |
| --- | --- | --- | --- |
| `firstName` | yes | non-blank | Stored in registration session |
| `lastName` | yes | non-blank | Stored in registration session |
| `idType` | yes | `CIN` or `PASSPORT` | Mapped to T24 legal doc name |
| `idNumber` | yes | non-blank | Matched with T24 `LEGAL_ID` |
| `dateOfBirth` | yes | `yyyyMMdd`, exactly 8 digits | Matched with T24 `DATE_OF_BIRTH` |
| `phoneNumber` | yes | 8 to 15 digits | Must match T24 `SMS_1` after removing non-digits |

Success:

```json
{
  "success": true,
  "message": "Client verified. OTP sent to phone number.",
  "data": {
    "registrationSessionToken": "secure-token",
    "nextStep": "VERIFY_PHONE_OTP"
  },
  "timestamp": "2026-05-26T10:15:30.123456Z"
}
```

Important error codes:

| Error code | Meaning |
| --- | --- |
| `VALIDATION_ERROR` | Request field validation failed |
| `T24_CUSTOMER_NOT_FOUND` | T24 data not found or submitted phone does not match T24 phone |
| `CLIENT_ALREADY_REGISTERED` | T24 customer already has a digital account |
| `UNSUPPORTED_ID_TYPE` | Unsupported ID type |

### 2. Verify Phone OTP

```http
POST /api/v1/registration/verify-phone-otp
```

Request:

```json
{
  "registrationSessionToken": "secure-token",
  "otp": "123456"
}
```

Fields:

| Field | Required | Validation | Notes |
| --- | --- | --- | --- |
| `registrationSessionToken` | yes | non-blank | From verify-client response |
| `otp` | yes | non-blank | Generated as 6 digits; no DTO pattern currently enforces this |

Success:

```json
{
  "success": true,
  "message": "Phone number verified successfully.",
  "data": null,
  "timestamp": "2026-05-26T10:15:30.123456Z"
}
```

Important behavior:
- Phone OTP expires after 5 minutes.
- Maximum attempts: 3.
- Session expires after 30 minutes from verify-client.

Important error codes:

| Error code | Meaning |
| --- | --- |
| `INVALID_SESSION` | Registration session token not found |
| `SESSION_EXPIRED` | Registration session expired |
| `REGISTRATION_ALREADY_COMPLETED` | Session already completed |
| `T24_NOT_VERIFIED` | T24 verification missing |
| `PHONE_ALREADY_VERIFIED` | Phone already verified |
| `OTP_NOT_FOUND` | OTP not found |
| `OTP_ALREADY_USED` | OTP already used |
| `OTP_EXPIRED` | OTP expired |
| `OTP_MAX_ATTEMPTS_EXCEEDED` | Too many OTP attempts |
| `INVALID_OTP` | OTP value is wrong |

### 3. Send Email Verification

```http
POST /api/v1/registration/send-email-verification
```

Request:

```json
{
  "registrationSessionToken": "secure-token",
  "email": "amina@example.com"
}
```

Fields:

| Field | Required | Validation | Notes |
| --- | --- | --- | --- |
| `registrationSessionToken` | yes | non-blank | From verify-client response |
| `email` | yes | valid email | Backend trims and lowercases before storing |

Success:

```json
{
  "success": true,
  "message": "Email verification code sent.",
  "data": null,
  "timestamp": "2026-05-26T10:15:30.123456Z"
}
```

Important error codes:

| Error code | Meaning |
| --- | --- |
| `INVALID_SESSION` | Registration session token not found |
| `SESSION_EXPIRED` | Registration session expired |
| `REGISTRATION_ALREADY_COMPLETED` | Session already completed |
| `PHONE_NOT_VERIFIED` | Phone OTP must be verified first |
| `EMAIL_ALREADY_VERIFIED` | Email already verified |
| `EMAIL_SEND_FAILED` | Backend could not send email |

### 4. Verify Email Code

```http
POST /api/v1/registration/verify-email
```

Request:

```json
{
  "registrationSessionToken": "secure-token",
  "code": "123456"
}
```

Fields:

| Field | Required | Validation | Notes |
| --- | --- | --- | --- |
| `registrationSessionToken` | yes | non-blank | From verify-client response |
| `code` | yes | exactly 6 digits | Email verification code |

Success:

```json
{
  "success": true,
  "message": "Email verified successfully.",
  "data": null,
  "timestamp": "2026-05-26T10:15:30.123456Z"
}
```

Important behavior:
- Email code expires after 10 minutes.
- Maximum attempts: 3.

Important error codes:

| Error code | Meaning |
| --- | --- |
| `INVALID_SESSION` | Registration session token not found |
| `SESSION_EXPIRED` | Registration session expired |
| `REGISTRATION_ALREADY_COMPLETED` | Session already completed |
| `PHONE_NOT_VERIFIED` | Phone OTP must be verified first |
| `EMAIL_NOT_SUBMITTED` | Email has not been submitted |
| `EMAIL_CODE_NOT_FOUND` | Email code not found |
| `EMAIL_CODE_ALREADY_USED` | Email code already used |
| `EMAIL_CODE_EXPIRED` | Email code expired |
| `EMAIL_CODE_MAX_ATTEMPTS_EXCEEDED` | Too many email code attempts |
| `INVALID_EMAIL_CODE` | Email code value is wrong |

### 5. Complete Registration

```http
POST /api/v1/registration/complete
```

Request:

```json
{
  "registrationSessionToken": "secure-token",
  "password": "Password1@"
}
```

Fields:

| Field | Required | Validation | Notes |
| --- | --- | --- | --- |
| `registrationSessionToken` | yes | non-blank | From verify-client response |
| `password` | yes | see regex below | Chosen password |

Password rules:
- Minimum 10 characters.
- At least one lowercase letter.
- At least one uppercase letter.
- At least one digit.
- At least one of these symbols: `@#$%&*?`
- Only these characters are allowed: letters, digits, `@#$%&*?`

Equivalent frontend regex:

```ts
/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%&*?])[A-Za-z\d@#$%&*?]{10,}$/
```

Success:

```json
{
  "success": true,
  "message": "Registration completed successfully.",
  "data": {
    "userId": 1,
    "username": "amina@example.com",
    "accountStatus": "ACTIVE",
    "firstLoginRequired": false
  },
  "timestamp": "2026-05-26T10:15:30.123456Z"
}
```

Notes:
- `username` currently contains the saved email.
- Account is created as `ACTIVE`.

Important error codes:

| Error code | Meaning |
| --- | --- |
| `INVALID_SESSION` | Registration session token not found |
| `SESSION_EXPIRED` | Registration session expired |
| `REGISTRATION_ALREADY_COMPLETED` | Session already completed |
| `T24_NOT_VERIFIED` | T24 verification missing |
| `PHONE_NOT_VERIFIED` | Phone not verified |
| `EMAIL_NOT_VERIFIED` | Email not verified |
| `EMAIL_REQUIRED` | Email missing in session |
| `T24_CUSTOMER_ID_REQUIRED` | T24 customer ID missing in session |
| `CLIENT_ALREADY_REGISTERED` | T24 customer already registered |
| `EMAIL_ALREADY_USED` | Email already used |
| `PHONE_ALREADY_USED` | Phone number already used |
| `REGISTRATION_SUCCESS_EMAIL_FAILED` | Account created but success email failed in current transactional flow |

## Auth Flow

Login uses three steps: verify credentials, choose an available MFA channel, and verify the OTP. The JWT is issued only after the final step.

### 1. Verify Login Credentials

```http
POST /api/v1/auth/login
```

Request:

```json
{
  "email": "amina@example.com",
  "password": "Password1@"
}
```

Fields:

| Field | Required | Validation | Notes |
| --- | --- | --- | --- |
| `email` | yes | valid email | Backend trims and lowercases before lookup |
| `password` | yes | non-blank | Raw password |

Success:

```json
{
  "success": true,
  "message": "Login credentials verified.",
  "data": {
    "challengeId": 42,
    "challengeToken": "5fa0e047-7876-48e4-a8a9-73dd83aa6168",
    "mfaRequired": true,
    "availableChannels": [
      {
        "channel": "PHONE",
        "maskedDestination": "****3456"
      },
      {
        "channel": "EMAIL",
        "maskedDestination": "am****@example.com"
      }
    ],
    "expiresAt": "2026-07-20T10:20:30.123456Z"
  },
  "timestamp": "2026-07-20T10:15:30.123456Z"
}
```

Frontend behavior:
- Keep both `challengeId` and `challengeToken` temporarily.
- Show only the entries returned in `availableChannels` and let the user select one.
- Do not treat this response as an authenticated session; it contains no access token.

### 2. Choose MFA Channel and Send OTP

```http
POST /api/v1/auth/login/choose-mfa
```

Request:

```json
{
  "challengeId": 42,
  "challengeToken": "5fa0e047-7876-48e4-a8a9-73dd83aa6168",
  "mfaChannel": "PHONE"
}
```

| Field | Required | Validation | Notes |
| --- | --- | --- | --- |
| `challengeId` | yes | numeric ID | Value returned by step 1 |
| `challengeToken` | yes | non-blank opaque value | Must be sent unchanged; do not expose it in URLs |
| `mfaChannel` | yes | `PHONE` or `EMAIL` | Must be one of the options returned by step 1 |

Success:

```json
{
  "success": true,
  "message": "Login OTP sent.",
  "data": {
    "challengeId": 42,
    "channel": "PHONE",
    "maskedDestination": "****3456",
    "expiresAt": "2026-07-20T10:21:00.123456Z"
  },
  "timestamp": "2026-07-20T10:16:00.123456Z"
}
```

The OTP contains exactly 6 digits and expires after 5 minutes. Keep the original `challengeToken` for step 3.

### 3. Verify Login OTP

```http
POST /api/v1/auth/login/verify-otp
```

Request:

```json
{
  "challengeId": 42,
  "challengeToken": "5fa0e047-7876-48e4-a8a9-73dd83aa6168",
  "otp": "123456"
}
```

Fields:

| Field | Required | Validation | Notes |
| --- | --- | --- | --- |
| `challengeId` | yes | numeric ID | Value returned by the first login step |
| `challengeToken` | yes | non-blank opaque value | Same value returned by step 1 |
| `otp` | yes | exactly 6 digits | Single-use code sent through the selected channel |

Success:

```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "accessToken": "jwt-token",
    "tokenType": "Bearer",
    "expiresInSeconds": 900,
    "userId": 1,
    "email": "amina@example.com",
    "firstName": "Amina",
    "lastName": "Ben Ali",
    "accountStatus": "ACTIVE"
  },
  "timestamp": "2026-07-20T10:16:00.123456Z"
}
```

Frontend storage:
- Store `accessToken` according to the frontend security decision only after this step succeeds.
- Send protected requests with `Authorization: Bearer <accessToken>`.
- Token expiration is currently configured as 15 minutes and returned as `expiresInSeconds`.

Important behavior:
- After 5 failed password attempts for an existing user, account is locked for 15 minutes.
- `SUSPENDED` and `CLOSED` accounts cannot login.
- A challenge permits at most 3 incorrect OTP attempts.
- OTPs are single-use. A used or expired challenge cannot issue another JWT.
- Selecting `PHONE` requires a verified phone number; selecting `EMAIL` requires a verified email address.
- The channel can be selected only once for each challenge.

Important error codes:

| Error code | Meaning |
| --- | --- |
| `VALIDATION_ERROR` | Request field validation failed |
| `BAD_CREDENTIALS` | Email or password is wrong |
| `ACCOUNT_NOT_ALLOWED` | Account is suspended or closed |
| `ACCOUNT_LOCKED` | Account is temporarily locked |
| `MFA_DESTINATION_REQUIRED` | User has no verified phone or email destination |
| `VERIFIED_PHONE_REQUIRED` | `PHONE` selected but the user has no verified phone number |
| `VERIFIED_EMAIL_REQUIRED` | `EMAIL` selected but the user has no verified email address |
| `MFA_CHANNEL_ALREADY_SELECTED` | A channel was already selected for this challenge |
| `MFA_CHANNEL_NOT_SELECTED` | OTP verification attempted before selecting a channel |
| `LOGIN_OTP_SEND_FAILED` | The selected provider could not deliver the OTP |
| `LOGIN_CHALLENGE_NOT_FOUND` | Challenge ID/token combination is invalid |
| `LOGIN_CHALLENGE_EXPIRED` | Credential challenge has expired or was already consumed |
| `INVALID_OTP` | Submitted OTP is incorrect |
| `OTP_EXPIRED` | Challenge OTP has expired |
| `OTP_ALREADY_USED` | Challenge OTP has already been consumed |
| `OTP_MAX_ATTEMPTS_EXCEEDED` | Three incorrect OTP attempts have been reached |

## Health Endpoint

```http
GET /actuator/health
```

Public endpoint exposed by Spring Actuator. Typical response:

```json
{
  "status": "UP"
}
```

## Frontend Implementation Notes

- Use a registration state machine matching backend `nextStep` values. Currently the only returned `nextStep` is `VERIFY_PHONE_OTP`.
- Keep `registrationSessionToken` in memory or short-lived session storage during registration. It is required for all registration continuation calls.
- Treat all business errors as structured `ErrorResponse`, even when HTTP status is `400`.
- Display validation `details[]` field-level messages when `errorCode` is `VALIDATION_ERROR`.
- For `/verify-client`, do not let the user proceed when `T24_CUSTOMER_NOT_FOUND` or `CLIENT_ALREADY_REGISTERED` is returned.
- The backend does not currently expose logout, refresh token, current-user profile, or login-OTP resend endpoints.
- The login challenge response returns masked destinations only; never display or infer complete destinations.
- Keep `challengeToken` in memory or short-lived session storage and never place it in a query string.
