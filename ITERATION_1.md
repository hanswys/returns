# Smart Reverse Logistics Portal (RPaaS)

## Iteration 1: Foundation & Data Modeling

### Project Overview
A comprehensive reverse logistics platform that allows merchants to define return rules and customers to initiate returns based on those rules. Built with SOLID principles and Low-Level Design (LLD) patterns.

**Tech Stack:**
- Backend: Ruby on Rails 8.1 (API mode) + PostgreSQL
- Frontend: React 18 + Tailwind CSS + TanStack Query
- State Management: AASM (State Machine)

---

## Backend Setup (Rails API)

### Database Schema

#### Models & Relationships
```
Merchant (1) ──→ (∞) Product
    ↓
    ├─→ (∞) Order
    ├─→ (∞) ReturnRule
    └─→ (∞) ReturnRequest

Order (1) ──→ (∞) ReturnRequest
Product (1) ──→ (∞) ReturnRequest
Product (1) ──→ (∞) ReturnRule
```

### Created Models

#### 1. **Merchant**
```ruby
class Merchant < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :return_rules, dependent: :destroy
  has_many :return_requests, dependent: :destroy

  enum status: { active: 0, inactive: 1, suspended: 2 }
  
  validates :name, :email, presence: true
  validates :email, uniqueness: true
end
```

**Attributes:**
- `name` (string): Merchant name
- `email` (string, unique): Merchant email
- `contact_person` (string): Contact person name
- `address` (text): Physical address
- `status` (enum): active, inactive, suspended
- `created_at`, `updated_at`

#### 2. **Product**
```ruby
class Product < ApplicationRecord
  belongs_to :merchant
  has_many :return_rules, dependent: :destroy
  has_many :return_requests, dependent: :destroy

  validates :name, :sku, presence: true
  validates :sku, uniqueness: { scope: :merchant_id }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
```

**Attributes:**
- `name` (string): Product name
- `sku` (string): Stock Keeping Unit (unique per merchant)
- `description` (text): Product description
- `price` (decimal): Product price
- `merchant_id` (foreign key)

#### 3. **Order**
```ruby
class Order < ApplicationRecord
  belongs_to :merchant
  has_many :return_requests, dependent: :destroy

  enum status: { pending: 0, confirmed: 1, shipped: 2, delivered: 3, cancelled: 4 }
  
  validates :order_number, uniqueness: { scope: :merchant_id }
  validates :customer_email, :customer_name, :total_amount, :order_date, presence: true
end
```

**Attributes:**
- `order_number` (string, unique per merchant): Order identifier
- `customer_email` (string): Customer email
- `customer_name` (string): Customer name
- `merchant_id` (foreign key)
- `total_amount` (decimal): Total order value
- `order_date` (datetime): Order creation date
- `status` (enum): pending, confirmed, shipped, delivered, cancelled

#### 4. **ReturnRequest** (State Machine)
```ruby
class ReturnRequest < ApplicationRecord
  include AASM

  belongs_to :order
  belongs_to :product
  belongs_to :merchant

  aasm column: :status, enum: true do
    state :requested, initial: true
    state :approved
    state :rejected
    state :shipped
    state :received
    state :resolved

    event :approve do
      transitions from: :requested, to: :approved
    end

    event :reject do
      transitions from: :requested, to: :rejected
    end

    event :ship do
      transitions from: :approved, to: :shipped
    end

    event :mark_received do
      transitions from: :shipped, to: :received
    end

    event :resolve do
      transitions from: :received, to: :resolved
    end

    event :reset_request do
      transitions from: [:rejected, :resolved], to: :requested
    end
  end
end
```

**Attributes:**
- `order_id` (foreign key)
- `product_id` (foreign key)
- `merchant_id` (foreign key)
- `reason` (text): Return reason
- `requested_date` (datetime): When return was requested
- `status` (enum): State machine states

**State Transitions:**
```
requested → approved → shipped → received → resolved
   ↓
rejected
```

#### 5. **ReturnRule**
```ruby
class ReturnRule < ApplicationRecord
  belongs_to :merchant
  belongs_to :product, optional: true

  validates :window_days, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validate :at_least_one_option_enabled
end
```

**Attributes:**
- `merchant_id` (foreign key)
- `product_id` (foreign key, optional): Specific product or null for merchant-wide rule
- `window_days` (integer): Return window in days
- `reason` (string): Reason category (e.g., "defective", "wrong_item")
- `replacement_allowed` (boolean): Allow replacement
- `refund_allowed` (boolean): Allow refund

---

## API Endpoints

### Base URL: `http://localhost:3000/api/v1`

#### Merchants
```
GET    /merchants                    # List all merchants
GET    /merchants/:id                # Get merchant details
POST   /merchants                    # Create merchant
PUT    /merchants/:id                # Update merchant
DELETE /merchants/:id                # Delete merchant
```

#### Products
```
GET    /merchants/:merchant_id/products              # List merchant products
GET    /merchants/:merchant_id/products/:id          # Get product
POST   /merchants/:merchant_id/products              # Create product
PUT    /merchants/:merchant_id/products/:id          # Update product
DELETE /merchants/:merchant_id/products/:id          # Delete product
```

#### Orders
```
GET    /orders                       # List all orders
GET    /orders/:id                   # Get order details
POST   /orders                       # Create order
PUT    /orders/:id                   # Update order
DELETE /orders/:id                   # Delete order
```

#### Return Requests
```
GET    /return_requests              # List all return requests
GET    /return_requests/:id          # Get return request
POST   /return_requests              # Create return request
PUT    /return_requests/:id          # Update return request
DELETE /return_requests/:id          # Delete return request
PATCH  /return_requests/:id/approve  # Approve return
PATCH  /return_requests/:id/reject   # Reject return
PATCH  /return_requests/:id/ship     # Ship return
PATCH  /return_requests/:id/mark_received  # Mark received
PATCH  /return_requests/:id/resolve  # Resolve return
```

#### Return Rules
```
GET    /merchants/:merchant_id/return_rules              # List rules
GET    /merchants/:merchant_id/return_rules/:id          # Get rule
POST   /merchants/:merchant_id/return_rules              # Create rule
PUT    /merchants/:merchant_id/return_rules/:id          # Update rule
DELETE /merchants/:merchant_id/return_rules/:id          # Delete rule
```

---

## Frontend Setup (React)

### Project Structure
```
returns-frontend/
├── src/
│   ├── api/
│   │   ├── apiClient.js         # Axios instance with interceptors
│   │   └── endpoints.js         # API endpoint definitions
│   ├── hooks/
│   │   └── useApi.js            # TanStack Query hooks
│   ├── components/
│   │   └── Merchants/
│   │       ├── MerchantList.js   # List all merchants
│   │       ├── MerchantCard.js   # Individual merchant card
│   │       └── MerchantForm.js   # Create/edit merchant form
│   ├── pages/
│   │   └── Dashboard.js         # Main dashboard page
│   ├── App.js                   # Root component with TanStack Query
│   ├── index.css                # Tailwind + global styles
│   └── index.js
├── tailwind.config.js           # Tailwind CSS config
├── postcss.config.js            # PostCSS config
└── package.json
```

### Key Features

#### 1. **API Client** (`apiClient.js`)
- Centralized Axios instance
- Request/response interceptors
- Token-based authentication ready
- Error handling

#### 2. **Custom Hooks** (`useApi.js`)
- `useMerchants()` - Fetch all merchants
- `useMerchant(id)` - Fetch single merchant
- `useCreateMerchant()` - Create new merchant
- `useUpdateMerchant()` - Update merchant
- `useDeleteMerchant()` - Delete merchant
- Similar hooks for Products, Orders, ReturnRequests, ReturnRules

#### 3. **Components**
- **MerchantList**: Displays all merchants in a responsive grid
- **MerchantCard**: Individual merchant card with actions
- **MerchantForm**: Form to create new merchants
- **Dashboard**: Main entry point with navigation

#### 4. **State Management**
- TanStack Query for server state
- Automatic caching and refetching
- Optimistic updates support
- Query invalidation on mutations

---

## Running the Application

### Backend (Rails)

```bash
cd returns-api

# Install dependencies
bundle install

# Set up database
rails db:create
rails db:migrate

# Start server (port 3000)
rails s
```

### Frontend (React)

```bash
cd returns-frontend

# Install dependencies
npm install

# Start development server (port 3000)
npm start

# Note: React runs on port 3000, so ensure Rails is on port 3000
# They communicate via CORS configuration
```

### Database Credentials
- Database: PostgreSQL
- Development DB: `returns_api_development`
- Test DB: `returns_api_test`
- User: Default postgres user

---

## SOLID Principles Implementation

### Single Responsibility Principle (SRP)
- Controllers handle HTTP requests/responses
- Serializers handle data formatting
- Models handle business logic and validation

### Open/Closed Principle (OCP)
- Base controller for shared error handling
- AASM gem for state machine extensibility

### Liskov Substitution Principle (LSP)
- All models inherit from ApplicationRecord
- Consistent interface across all resources

### Interface Segregation Principle (ISP)
- Modular custom hooks for specific data needs
- API endpoints organized by resource

### Dependency Inversion Principle (DIP)
- Dependency injection through constructor
- Abstract API layer with axios client

---

## Design Patterns Used

### Backend
1. **Service Object Pattern** (Preparation for Iteration 2)
   - Return Rules Engine will use service objects
   - Validates return requests against rules

2. **State Machine Pattern** (AASM)
   - ReturnRequest lifecycle management
   - Clear state transitions

3. **Repository Pattern** (Rails Models)
   - Models encapsulate data access
   - Relationships define associations

### Frontend
1. **Custom Hooks Pattern**
   - Encapsulate API logic
   - Reusable data fetching
   - Automatic caching

2. **Component Composition**
   - Small, focused components
   - Props-based configuration
   - Container/Presenter pattern

3. **Query Pattern** (TanStack Query)
   - Centralized server state
   - Automatic synchronization

---

## Testing Endpoints

### Create Merchant (cURL)
```bash
curl -X POST http://localhost:3000/api/v1/merchants \
  -H "Content-Type: application/json" \
  -d '{
    "merchant": {
      "name": "Acme Corp",
      "email": "contact@acme.com",
      "contact_person": "John Doe",
      "address": "123 Main St"
    }
  }'
```

### Create Order
```bash
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Content-Type: application/json" \
  -d '{
    "order": {
      "order_number": "ORD-001",
      "customer_email": "customer@example.com",
      "customer_name": "Jane Doe",
      "merchant_id": 1,
      "total_amount": 199.99,
      "order_date": "2026-02-04T12:00:00Z"
    }
  }'
```

---

## Next Steps (Iteration 2)

1. **Return Rules Engine**
   - Service object for validating returns
   - Business logic implementation

2. **Authentication & Authorization**
   - JWT token-based auth
   - Role-based access control

3. **Advanced Filtering & Search**
   - Query parameters for filtering
   - Full-text search capabilities

4. **Error Handling**
   - Comprehensive error messages
   - Validation error details

5. **Testing**
   - Unit tests for models
   - Integration tests for APIs
   - E2E tests for frontend flows

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        Frontend (React)                      │
│  Dashboard → Components → Custom Hooks → API Client         │
└─────────────────────────┬───────────────────────────────────┘
                          │ HTTP (CORS)
                          │
┌─────────────────────────▼───────────────────────────────────┐
│              Backend (Rails API)                             │
│                                                               │
│  Routes → Controllers → Serializers → Models                 │
│                           ↓                                  │
│                      PostgreSQL                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Dependencies

### Backend (Gemfile)
```ruby
gem 'rails', '~> 8.1.2'
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'rack-cors'
gem 'aasm'
gem 'active_model_serializers', '~> 0.10.0'
```

### Frontend (package.json)
```json
{
  "react": "^18.2.0",
  "react-dom": "^18.2.0",
  "axios": "^latest",
  "@tanstack/react-query": "^latest",
  "tailwindcss": "^latest",
  "postcss": "^latest",
  "autoprefixer": "^latest"
}
```

---

## Status: ✅ Complete

**Iteration 1 Deliverables:**
- ✅ Rails API initialized with PostgreSQL
- ✅ React frontend with Tailwind CSS
- ✅ 5 Core models with relationships
- ✅ AASM state machine for ReturnRequest
- ✅ Complete API endpoints
- ✅ API serializers
- ✅ TanStack Query integration
- ✅ Frontend components
- ✅ CORS configuration

**Ready for review and feedback before proceeding to Iteration 2.**

---

*Last Updated: February 4, 2026*
