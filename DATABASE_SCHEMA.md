# Database Schema - Visual Reference

## Entity Relationship Diagram (ERD)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          MERCHANTS                                       │
├─────────────────────────────────────────────────────────────────────────┤
│ id (PK)              bigint                                              │
│ name                 varchar(255)        NOT NULL                        │
│ email                varchar(255)        NOT NULL, UNIQUE                │
│ contact_person       varchar(255)                                        │
│ address              text                                                │
│ status               integer             DEFAULT 0 (active)             │
│ created_at           timestamp                                           │
│ updated_at           timestamp                                           │
└─────────────────────────────────────────────────────────────────────────┘
                  │
                  │ (1) has_many (∞)
                  ├──────────────────┬──────────────────┬──────────────────┐
                  ▼                  ▼                  ▼                  ▼
        ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
        │   PRODUCTS       │  │    ORDERS        │  │  RETURN_RULES    │  │ RETURN_REQUESTS  │
        ├──────────────────┤  ├──────────────────┤  ├──────────────────┤  ├──────────────────┤
        │ id (PK)          │  │ id (PK)          │  │ id (PK)          │  │ id (PK)          │
        │ name             │  │ order_number     │  │ merchant_id (FK) │  │ order_id (FK)    │
        │ sku              │  │ customer_email   │  │ product_id (FK)  │  │ product_id (FK)  │
        │ description      │  │ customer_name    │  │ window_days      │  │ reason           │
        │ price            │  │ merchant_id (FK) │  │ reason           │  │ requested_date   │
        │ merchant_id (FK) │  │ total_amount     │  │ replacement_...  │  │ status           │
        │ created_at       │  │ order_date       │  │ refund_allowed   │  │ merchant_id (FK) │
        │ updated_at       │  │ status           │  │ created_at       │  │ created_at       │
        │                  │  │ created_at       │  │ updated_at       │  │ updated_at       │
        │                  │  │ updated_at       │  │                  │  │                  │
        └──────────────────┘  └──────────────────┘  └──────────────────┘  └──────────────────┘
                  │                    │                                          ▲
                  │                    │                                          │
                  │ (1) has_many (∞)   │ (1) has_many (∞)                        │
                  └────────────────┬───┘                                          │
                                   │                                              │
                                   └──────────────────────────────────────────────┘
                                     (1) belongs_to (∞)

```

---

## Table Schemas

### MERCHANTS
```sql
CREATE TABLE merchants (
  id bigint PRIMARY KEY AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  email varchar(255) NOT NULL UNIQUE,
  contact_person varchar(255),
  address text,
  status integer DEFAULT 0,  -- 0: active, 1: inactive, 2: suspended
  created_at timestamp,
  updated_at timestamp,
  
  INDEX idx_status (status),
  CONSTRAINT merchants_email_unique UNIQUE (email)
);
```

**Enum Values for `status`:**
- 0 = active
- 1 = inactive
- 2 = suspended

---

### PRODUCTS
```sql
CREATE TABLE products (
  id bigint PRIMARY KEY AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  sku varchar(255) NOT NULL,
  description text,
  price decimal(10,2) NOT NULL,
  merchant_id bigint NOT NULL,
  created_at timestamp,
  updated_at timestamp,
  
  CONSTRAINT fk_product_merchant FOREIGN KEY (merchant_id)
    REFERENCES merchants(id) ON DELETE CASCADE,
  UNIQUE INDEX idx_merchant_sku (merchant_id, sku)
);
```

**Constraints:**
- SKU must be unique per merchant (composite key)
- Foreign key to merchants with CASCADE delete

---

### ORDERS
```sql
CREATE TABLE orders (
  id bigint PRIMARY KEY AUTO_INCREMENT,
  order_number varchar(255) NOT NULL,
  customer_email varchar(255) NOT NULL,
  customer_name varchar(255) NOT NULL,
  merchant_id bigint NOT NULL,
  total_amount decimal(12,2) NOT NULL,
  order_date datetime NOT NULL,
  status integer DEFAULT 0,  -- 0: pending, 1: confirmed, 2: shipped, 3: delivered, 4: cancelled
  created_at timestamp,
  updated_at timestamp,
  
  CONSTRAINT fk_order_merchant FOREIGN KEY (merchant_id)
    REFERENCES merchants(id) ON DELETE CASCADE,
  UNIQUE INDEX idx_merchant_order_number (merchant_id, order_number),
  INDEX idx_customer_email (customer_email),
  INDEX idx_status (status)
);
```

**Enum Values for `status`:**
- 0 = pending
- 1 = confirmed
- 2 = shipped
- 3 = delivered
- 4 = cancelled

---

### RETURN_REQUESTS
```sql
CREATE TABLE return_requests (
  id bigint PRIMARY KEY AUTO_INCREMENT,
  order_id bigint NOT NULL,
  product_id bigint NOT NULL,
  reason text NOT NULL,
  requested_date datetime NOT NULL,
  status integer DEFAULT 0,  -- AASM states
  merchant_id bigint NOT NULL,
  created_at timestamp,
  updated_at timestamp,
  
  CONSTRAINT fk_rr_order FOREIGN KEY (order_id)
    REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_rr_product FOREIGN KEY (product_id)
    REFERENCES products(id) ON DELETE CASCADE,
  CONSTRAINT fk_rr_merchant FOREIGN KEY (merchant_id)
    REFERENCES merchants(id) ON DELETE CASCADE,
  UNIQUE INDEX idx_order_product (order_id, product_id),
  INDEX idx_status (status)
);
```

**Enum Values for `status` (AASM States):**
- 0 = requested
- 1 = approved
- 2 = rejected
- 3 = shipped
- 4 = received
- 5 = resolved

**State Transitions:**
```
requested ──approve──> approved ──ship──> shipped ──mark_received──> received ──resolve──> resolved
   │
   └─ reject ──> rejected ──reset_request──┐
                                           │
   ┌─────────────────────────────────────┘
   └─> requested
```

---

### RETURN_RULES
```sql
CREATE TABLE return_rules (
  id bigint PRIMARY KEY AUTO_INCREMENT,
  merchant_id bigint NOT NULL,
  product_id bigint,  -- NULL for merchant-wide rules
  window_days integer NOT NULL,
  reason varchar(255),
  replacement_allowed boolean DEFAULT true,
  refund_allowed boolean DEFAULT true,
  created_at timestamp,
  updated_at timestamp,
  
  CONSTRAINT fk_rr_merchant FOREIGN KEY (merchant_id)
    REFERENCES merchants(id) ON DELETE CASCADE,
  CONSTRAINT fk_rr_product FOREIGN KEY (product_id)
    REFERENCES products(id) ON DELETE CASCADE,
  UNIQUE INDEX idx_merchant_product (merchant_id, product_id)
);
```

**Constraints:**
- At least one of `replacement_allowed` or `refund_allowed` must be TRUE
- Product can be NULL (merchant-wide rule)
- Window days must be >= 1

---

## Relationships Summary

| From | To | Type | Cascade |
|------|-----|------|---------|
| Merchant | Product | 1:N | DELETE |
| Merchant | Order | 1:N | DELETE |
| Merchant | ReturnRule | 1:N | DELETE |
| Merchant | ReturnRequest | 1:N | DELETE |
| Product | ReturnRule | 1:N | DELETE |
| Product | ReturnRequest | 1:N | DELETE |
| Order | ReturnRequest | 1:N | DELETE |

---

## Index Strategy

| Table | Index | Type | Purpose |
|-------|-------|------|---------|
| merchants | email | UNIQUE | Quick lookup, prevent duplicates |
| merchants | status | REGULAR | Filter by merchant status |
| products | merchant_id, sku | UNIQUE | Enforce SKU uniqueness per merchant |
| orders | merchant_id, order_number | UNIQUE | Enforce order number uniqueness |
| orders | customer_email | REGULAR | Search orders by email |
| orders | status | REGULAR | Filter by order status |
| return_requests | order_id, product_id | UNIQUE | One return per product per order |
| return_requests | status | REGULAR | Filter by return status |
| return_rules | merchant_id, product_id | UNIQUE | One rule per product per merchant |

---

## Sample Data Flow

### 1. Merchant Creates an Order
```
POST /api/v1/orders
{
  "order": {
    "order_number": "ORD-2026-0001",
    "customer_email": "john@example.com",
    "customer_name": "John Smith",
    "merchant_id": 1,
    "total_amount": 199.99,
    "order_date": "2026-02-04T10:00:00Z"
  }
}

↓ Creates Order record with status = pending
```

### 2. Customer Requests Return
```
POST /api/v1/return_requests
{
  "return_request": {
    "order_id": 1,
    "product_id": 1,
    "merchant_id": 1,
    "reason": "Product damaged",
    "requested_date": "2026-02-05T14:00:00Z"
  }
}

↓ Creates ReturnRequest with status = requested
```

### 3. Merchant Approves Return
```
PATCH /api/v1/return_requests/1/approve

↓ Transitions status: requested → approved
↓ AASM ensures valid transition
```

### 4. Return Shipped
```
PATCH /api/v1/return_requests/1/ship

↓ Transitions status: approved → shipped
```

### 5. Return Received & Resolved
```
PATCH /api/v1/return_requests/1/mark_received
↓ Transitions status: shipped → received

PATCH /api/v1/return_requests/1/resolve
↓ Transitions status: received → resolved
```

---

## Validation Rules

### Merchants
- ✅ `name` - Required, non-empty string
- ✅ `email` - Required, valid email, globally unique
- ✅ `status` - Valid enum value

### Products
- ✅ `name` - Required, non-empty string
- ✅ `sku` - Required, unique per merchant
- ✅ `price` - Required, >= 0
- ✅ `merchant_id` - Required foreign key

### Orders
- ✅ `order_number` - Required, unique per merchant
- ✅ `customer_email` - Required, valid email
- ✅ `customer_name` - Required, non-empty string
- ✅ `total_amount` - Required, >= 0
- ✅ `order_date` - Required, valid datetime

### ReturnRequests
- ✅ `reason` - Required, non-empty text
- ✅ `requested_date` - Required, valid datetime
- ✅ `status` - AASM enforced valid states & transitions
- ✅ Foreign keys - All required and valid

### ReturnRules
- ✅ `window_days` - Required, >= 1
- ✅ At least one flag - `replacement_allowed` OR `refund_allowed`
- ✅ Foreign keys - merchant_id required, product_id optional

---

*Schema finalized: February 4, 2026*
