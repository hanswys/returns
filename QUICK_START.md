# Quick Start Guide - Smart Reverse Logistics Portal

## 🚀 5-Minute Setup

### Prerequisites
- Ruby 3.2+ installed
- PostgreSQL running
- Node.js 16+ installed
- npm or yarn

### Step 1: Backend Setup (Rails)
```bash
cd returns-api
bundle install
rails db:create db:migrate
rails s
```
✅ Backend ready at `http://localhost:3000`

### Step 2: Frontend Setup (React)
Open another terminal:
```bash
cd returns-frontend
npm install
npm start
```
✅ Frontend ready at `http://localhost:3001` (or auto-assigned port)

---

## 📱 Application Features

### Merchants Management
- ✅ Create merchants with contact info
- ✅ View all merchants with status badges
- ✅ Update merchant details
- ✅ Delete merchants

### Products Management
- ✅ Add products to merchants
- ✅ Track SKU (unique per merchant)
- ✅ Manage pricing

### Orders Management
- ✅ Create customer orders
- ✅ Track order status (pending, confirmed, shipped, delivered, cancelled)
- ✅ Link products to orders

### Return Requests (State Machine)
- ✅ Initiate return requests
- ✅ Approve/Reject returns
- ✅ Track return shipment
- ✅ Manage return workflow
- **States**: requested → approved → shipped → received → resolved

### Return Rules
- ✅ Define return windows (days)
- ✅ Set replacement/refund policies
- ✅ Product-specific or merchant-wide rules

---

## 🔗 API Quick Reference

### Base URL
```
http://localhost:3000/api/v1
```

### Create Merchant (POST)
```bash
curl -X POST http://localhost:3000/api/v1/merchants \
  -H "Content-Type: application/json" \
  -d '{
    "merchant": {
      "name": "Acme Corp",
      "email": "contact@acme.com",
      "contact_person": "John Doe",
      "address": "123 Main St, City"
    }
  }'
```

### Get All Merchants (GET)
```bash
curl http://localhost:3000/api/v1/merchants
```

### Create Product (POST)
```bash
curl -X POST http://localhost:3000/api/v1/merchants/1/products \
  -H "Content-Type: application/json" \
  -d '{
    "product": {
      "name": "Widget Pro",
      "sku": "WP-001",
      "description": "Professional widget",
      "price": 99.99
    }
  }'
```

### Create Order (POST)
```bash
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Content-Type: application/json" \
  -d '{
    "order": {
      "order_number": "ORD-2026-001",
      "customer_email": "customer@example.com",
      "customer_name": "Jane Smith",
      "merchant_id": 1,
      "total_amount": 299.97,
      "order_date": "2026-02-04T12:00:00Z"
    }
  }'
```

### Create Return Request (POST)
```bash
curl -X POST http://localhost:3000/api/v1/return_requests \
  -H "Content-Type: application/json" \
  -d '{
    "return_request": {
      "order_id": 1,
      "product_id": 1,
      "merchant_id": 1,
      "reason": "Product damaged in shipping",
      "requested_date": "2026-02-05T10:00:00Z"
    }
  }'
```

### Approve Return (PATCH)
```bash
curl -X PATCH http://localhost:3000/api/v1/return_requests/1/approve
```

### Ship Return (PATCH)
```bash
curl -X PATCH http://localhost:3000/api/v1/return_requests/1/ship
```

### Mark Received (PATCH)
```bash
curl -X PATCH http://localhost:3000/api/v1/return_requests/1/mark_received
```

### Resolve Return (PATCH)
```bash
curl -X PATCH http://localhost:3000/api/v1/return_requests/1/resolve
```

---

## 📂 Project Structure

```
returns/
├── returns-api/                 # Rails Backend
│   ├── app/models/
│   │   ├── merchant.rb         # Merchant model with validations
│   │   ├── product.rb          # Product model
│   │   ├── order.rb            # Order model
│   │   ├── return_request.rb   # ReturnRequest with AASM
│   │   └── return_rule.rb      # ReturnRule model
│   ├── app/controllers/api/v1/
│   │   ├── merchants_controller.rb
│   │   ├── products_controller.rb
│   │   ├── orders_controller.rb
│   │   ├── return_requests_controller.rb
│   │   └── return_rules_controller.rb
│   ├── app/serializers/        # JSON serializers
│   ├── db/migrate/             # Database migrations
│   ├── config/routes.rb        # API routes
│   └── Gemfile                 # Dependencies
│
├── returns-frontend/           # React Frontend
│   ├── src/
│   │   ├── api/
│   │   │   ├── apiClient.js    # Axios HTTP client
│   │   │   └── endpoints.js    # API endpoint definitions
│   │   ├── hooks/
│   │   │   └── useApi.js       # TanStack Query hooks
│   │   ├── components/
│   │   │   └── Merchants/
│   │   │       ├── MerchantList.js
│   │   │       ├── MerchantCard.js
│   │   │       └── MerchantForm.js
│   │   ├── pages/
│   │   │   └── Dashboard.js    # Main app page
│   │   ├── App.js              # Root component
│   │   └── index.css           # Tailwind CSS
│   ├── tailwind.config.js
│   ├── postcss.config.js
│   └── package.json
│
├── ITERATION_1.md              # Comprehensive documentation
├── ITERATION_1_SUMMARY.md      # Quick summary
├── DATABASE_SCHEMA.md          # Schema reference
└── setup.sh                    # Automated setup script
```

---

## 🛠️ Tech Stack Details

### Backend (Rails)
| Package | Version | Purpose |
|---------|---------|---------|
| Rails | 8.1 | Web framework |
| PostgreSQL | 16 | Database |
| AASM | 5.5 | State machine |
| AMS | 0.10 | JSON serialization |
| Rack-CORS | Latest | CORS handling |

### Frontend (React)
| Package | Version | Purpose |
|---------|---------|---------|
| React | 18 | UI library |
| Tailwind CSS | 3 | Styling |
| TanStack Query | 5 | Server state |
| Axios | Latest | HTTP client |

---

## 🧪 Testing in Browser

### Via Frontend UI
1. Open `http://localhost:3001` (or shown port)
2. Click "Add Merchant"
3. Fill in merchant details
4. Submit form
5. See merchant appear in list

### Via cURL (Command Line)

#### Test Health Check
```bash
curl http://localhost:3000/up
# Returns 200 if API is running
```

#### Test Merchants Endpoint
```bash
curl -s http://localhost:3000/api/v1/merchants | jq .
# Returns JSON array of merchants
```

---

## 🔄 Common Workflows

### Workflow 1: Create Complete Order with Return
```
1. Create Merchant
   POST /merchants

2. Create Product
   POST /merchants/{id}/products

3. Create Order
   POST /orders

4. Create Return Request
   POST /return_requests

5. Approve Return
   PATCH /return_requests/{id}/approve

6. Ship Return
   PATCH /return_requests/{id}/ship

7. Mark Received
   PATCH /return_requests/{id}/mark_received

8. Resolve Return
   PATCH /return_requests/{id}/resolve
```

### Workflow 2: Reject Return Request
```
1. Create Return Request
   POST /return_requests (status: requested)

2. Reject
   PATCH /return_requests/{id}/reject (status: rejected)

3. Reset (optional)
   PATCH /return_requests/{id}/reset (status: requested)
```

---

## 📊 Data Model Overview

### Merchant
A seller that uses the platform to manage returns.

**Key Attributes:**
- name, email, contact_person, address
- status: active | inactive | suspended

### Product
Items sold by merchants.

**Key Attributes:**
- name, sku (unique per merchant), description, price

### Order
Customer purchases from merchants.

**Key Attributes:**
- order_number, customer_email, customer_name
- total_amount, order_date
- status: pending | confirmed | shipped | delivered | cancelled

### ReturnRequest
Customer returns product from an order.

**State Machine (AASM):**
```
requested
  ├──approve──→ approved ──ship──→ shipped ──mark_received──→ received ──resolve──→ resolved
  └──reject──→ rejected ──reset_request──→ requested
```

### ReturnRule
Policy for handling returns.

**Key Attributes:**
- window_days (return deadline)
- reason (category)
- replacement_allowed, refund_allowed (at least one must be true)

---

## ⚙️ Environment Configuration

### Backend (.env - create if needed)
```
RAILS_ENV=development
DATABASE_URL=postgresql://user:password@localhost/returns_api_development
CORS_ORIGINS=http://localhost:3001
```

### Frontend (.env - create if needed)
```
REACT_APP_API_URL=http://localhost:3000/api/v1
```

---

## 📚 Documentation Files

- **ITERATION_1.md** - Complete architecture, design patterns, relationships
- **ITERATION_1_SUMMARY.md** - Executive summary and highlights
- **DATABASE_SCHEMA.md** - Detailed schema reference with ERD
- **setup.sh** - Automated setup script
- **This file** - Quick start and quick reference

---

## 🔗 Important Links

- Rails API: http://localhost:3000
- React App: http://localhost:3001
- API Health: http://localhost:3000/up
- API Merchants: http://localhost:3000/api/v1/merchants

---

## 🚨 Troubleshooting

### PostgreSQL Connection Error
```
Error: could not connect to server
Solution: brew services start postgresql@16
```

### Port Already in Use
```
Error: Port 3000 already in use
Solution: 
  - Kill process: lsof -ti :3000 | xargs kill -9
  - Or use: rails s -p 3001
```

### CORS Error
```
Error: No 'Access-Control-Allow-Origin' header
Solution: Check config/initializers/cors.rb is uncommented
```

### Database Migration Error
```
Error: PG::DuplicateTable
Solution: rails db:reset (careful - deletes data!)
```

---

## ✅ Iteration 1 Status

**All Foundation Work Complete:**
- ✅ 5 Core models with relationships
- ✅ AASM state machine
- ✅ API endpoints
- ✅ Frontend components
- ✅ TanStack Query integration
- ✅ Tailwind styling
- ✅ CORS enabled
- ✅ Database migrations
- ✅ Serializers

**Awaiting Review for Iteration 2:**
- Return Rules Engine
- Authentication
- Business Logic

---

*Last Updated: February 4, 2026*
*Ready for Review and "GO" Signal*
