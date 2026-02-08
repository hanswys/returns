# Smart Reverse Logistics Portal

A full-stack returns management system built with **Ruby on Rails API** and **React**. Enables merchants to configure return policies and customers to submit return requests with automated eligibility checking and shipping label generation.

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Backend** | Rails 8.1.2 (API-only), PostgreSQL |
| **Frontend** | React 18, Vite |
| **State Machine** | AASM |
| **Background Jobs** | Solid Queue |
| **PDF Generation** | Prawn + RQRCode |

---

## Quick Start

```bash
# Clone and setup
git clone https://github.com/hanswys/returns.git
cd returns
./setup.sh

# Terminal 1 - Backend
cd returns-api
rails s

# Terminal 2 - Frontend
cd returns-frontend
npm start

# Terminal 3 - Background Jobs
cd returns-api
bin/jobs
```

**Access:**
- Backend: http://localhost:3000
- Frontend: http://localhost:3001

---

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  React Frontend │────▶│   Rails API     │────▶│   PostgreSQL    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                               │
                               ▼
                        ┌─────────────────┐
                        │  Solid Queue    │
                        │  (Background)   │
                        └─────────────────┘
```

---

## API Endpoints

| Resource | Endpoints |
|----------|-----------|
| **Return Requests** | `GET/POST /api/v1/return_requests`, `PATCH/:id/approve`, `PATCH/:id/reject`, `PATCH/:id/ship` |
| **Orders** | `GET/POST /api/v1/orders` |
| **Merchants** | `GET/POST /api/v1/merchants` |
| **Products** | `GET/POST /api/v1/products` |
| **Return Rules** | `GET/POST /api/v1/return_rules` |
| **Analytics** | `GET /api/v1/analytics` |
| **Webhooks** | `POST /api/v1/webhooks` |

---

## Key Features

### Return Request Lifecycle (AASM)

```
requested → approved → shipped → received → resolved
    │
    └─→ rejected
```

### Eligibility Checking

Returns are validated against merchant-configured rules:
- **Date Threshold** — Is the order within the return window?
- **Price Threshold** — Order total eligibility check

### Strategy Pattern for Rules

New rule types can be added without modifying existing code:

```ruby
# app/services/return_rules/strategies/my_custom_strategy.rb
class MyCustomStrategy
  include Registry  # Auto-registers at boot
  
  def self.match?(config)
    config.key?('my_custom_key')
  end
  
  def decide
    # Custom logic → return Decision.new(:approve/:deny/:green_return)
  end
end
```

---

## Testing

```bash
cd returns-api
bundle exec rspec                    # All tests
bundle exec rspec spec/services/     # Service tests only
```

---

## Project Structure

```
returns/
├── returns-api/                 # Rails 8.1 API
│   ├── app/
│   │   ├── controllers/api/v1/  # REST endpoints
│   │   ├── models/              # ActiveRecord + AASM
│   │   ├── services/            # Business logic
│   │   │   ├── return_rules/    # Strategy pattern
│   │   │   └── ...
│   │   └── jobs/                # Background processing
│   └── spec/                    # RSpec tests
├── returns-frontend/            # React + Vite
│   └── src/
│       ├── components/          # UI components
│       ├── hooks/               # Custom React hooks
│       └── api/                 # API client
├── TRADEOFFS.md                 # Architecture decisions
└── setup.sh                     # One-command setup
```

---

## Documentation

- [TRADEOFFS.md](./TRADEOFFS.md) — Architecture decisions and design rationale

---

## License

MIT
