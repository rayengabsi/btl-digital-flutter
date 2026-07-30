# Subscription API

**Base URL**

```text
/api/v1/subscriptions
```

All endpoints require authentication and the authority listed below.

| Method   | Endpoint                                                             | Required Permission   | Description                             |
| -------- | -------------------------------------------------------------------- | --------------------- | --------------------------------------- |
| `PUT`    | `/api/v1/subscriptions/{subscriptionId}/client-users/{clientUserId}` | `SET_SUBSCRIPTION`    | Assign a subscription to a client user  |
| `POST`   | `/api/v1/subscriptions`                                              | `MANAGE_SUBSCRIPTION` | Create a new subscription               |
| `GET`    | `/api/v1/subscriptions`                                              | `SELECT_SUBSCRIPTION` | Retrieve all subscriptions              |
| `GET`    | `/api/v1/subscriptions/{id}`                                         | `SELECT_SUBSCRIPTION` | Retrieve a subscription by ID           |
| `PUT`    | `/api/v1/subscriptions/{id}`                                         | `MANAGE_SUBSCRIPTION` | Update an existing subscription         |
| `POST`   | `/api/v1/subscriptions/{subscriptionId}/permissions/{permissionId}`  | `MANAGE_PERMISSION`   | Add a permission to a subscription      |
| `DELETE` | `/api/v1/subscriptions/{subscriptionId}/permissions/{permissionId}`  | `MANAGE_PERMISSION`   | Remove a permission from a subscription |
| `DELETE` | `/api/v1/subscriptions/{id}`                                         | `MANAGE_SUBSCRIPTION` | Delete a subscription                   |

---

## 1. Assign Subscription to Client User

```http
PUT /api/v1/subscriptions/{subscriptionId}/client-users/{clientUserId}
```

**Required permission**

```text
SET_SUBSCRIPTION
```

**Path parameters**

| Parameter        | Type   | Description     |
| ---------------- | ------ | --------------- |
| `subscriptionId` | `Long` | Subscription ID |
| `clientUserId`   | `Long` | Client user ID  |

**Success response**

```text
200 OK
```

Returns a `SubscriptionResponse`.

---

## 2. Create Subscription

```http
POST /api/v1/subscriptions
```

**Required permission**

```text
MANAGE_SUBSCRIPTION
```

**Request body**

```json
{
  "name": "Premium",
  "description": "Premium subscription"
}
```

The exact fields depend on `SubscriptionRequest`.

**Success response**

```text
201 Created
```

Returns the created `SubscriptionResponse`.

---

## 3. Get All Subscriptions

```http
GET /api/v1/subscriptions
```

**Required permission**

```text
SELECT_SUBSCRIPTION
```

**Success response**

```text
200 OK
```

Returns a list of subscriptions.

```json
[
  {
    "id": 1,
    "name": "Premium"
  }
]
```

---

## 4. Get Subscription by ID

```http
GET /api/v1/subscriptions/{id}
```

**Required permission**

```text
SELECT_SUBSCRIPTION
```

**Path parameters**

| Parameter | Type   | Description     |
| --------- | ------ | --------------- |
| `id`      | `Long` | Subscription ID |

**Success response**

```text
200 OK
```

Returns a `SubscriptionResponse`.

---

## 5. Update Subscription

```http
PUT /api/v1/subscriptions/{id}
```

**Required permission**

```text
MANAGE_SUBSCRIPTION
```

**Path parameters**

| Parameter | Type   | Description     |
| --------- | ------ | --------------- |
| `id`      | `Long` | Subscription ID |

**Request body**

```json
{
  "name": "Updated Premium",
  "description": "Updated subscription"
}
```

The exact fields depend on `SubscriptionRequest`.

**Success response**

```text
200 OK
```

Returns the updated `SubscriptionResponse`.

---

## 6. Add Permission to Subscription

```http
POST /api/v1/subscriptions/{subscriptionId}/permissions/{permissionId}
```

**Required permission**

```text
MANAGE_PERMISSION
```

**Path parameters**

| Parameter        | Type   | Description          |
| ---------------- | ------ | -------------------- |
| `subscriptionId` | `Long` | Subscription ID      |
| `permissionId`   | `Long` | Permission ID to add |

**Success response**

```text
200 OK
```

Returns the updated `SubscriptionResponse`.

---

## 7. Remove Permission from Subscription

```http
DELETE /api/v1/subscriptions/{subscriptionId}/permissions/{permissionId}
```

**Required permission**

```text
MANAGE_PERMISSION
```

**Path parameters**

| Parameter        | Type   | Description             |
| ---------------- | ------ | ----------------------- |
| `subscriptionId` | `Long` | Subscription ID         |
| `permissionId`   | `Long` | Permission ID to remove |

**Success response**

```text
200 OK
```

Returns the updated `SubscriptionResponse`.

---

## 8. Delete Subscription

```http
DELETE /api/v1/subscriptions/{id}
```

**Required permission**

```text
MANAGE_SUBSCRIPTION
```

**Path parameters**

| Parameter | Type   | Description     |
| --------- | ------ | --------------- |
| `id`      | `Long` | Subscription ID |

**Success response**

```text
204 No Content
```

No response body.

---

## Permission Summary

| Permission            | Allowed Operations                       |
| --------------------- | ---------------------------------------- |
| `SET_SUBSCRIPTION`    | Assign a subscription to a client user   |
| `SELECT_SUBSCRIPTION` | View subscriptions                       |
| `MANAGE_SUBSCRIPTION` | Create, update, and delete subscriptions |
| `MANAGE_PERMISSION`   | Add or remove subscription permissions   |

## Common Error Responses

| Status                      | Meaning                                                |
| --------------------------- | ------------------------------------------------------ |
| `400 Bad Request`           | Invalid request body or validation error               |
| `401 Unauthorized`          | User is not authenticated                              |
| `403 Forbidden`             | User does not have the required permission             |
| `404 Not Found`             | Subscription, client user, or permission was not found |
| `500 Internal Server Error` | Unexpected server error                                |
