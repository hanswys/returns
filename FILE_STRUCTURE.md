# Smart Reverse Logistics Portal - Complete File Structure

## Project Root Structure

```
/Users/hans/Desktop/ruby-apps/returns/
│
├── 📖 DOCUMENTATION (6 files)
│   ├── README.md                      ← Start here! Documentation index
│   ├── QUICK_START.md                 ← 5-min setup & API reference  
│   ├── ITERATION_1.md                 ← Complete architecture guide
│   ├── ITERATION_1_SUMMARY.md         ← Executive summary
│   ├── DATABASE_SCHEMA.md             ← Schema reference with ERD
│   ├── SETUP_COMPLETE.md              ← Iteration 1 status report
│   └── setup.sh                       ← Automated setup script
│
├── 🚀 BACKEND (Rails API)
│   └── returns-api/
│       ├── app/
│       │   ├── controllers/
│       │   │   ├── application_controller.rb
│       │   │   └── api/v1/            ← API Controllers (6 files)
│       │   │       ├── base_controller.rb
│       │   │       ├── merchants_controller.rb
│       │   │       ├── products_controller.rb
│       │   │       ├── orders_controller.rb
│       │   │       ├── return_requests_controller.rb
│       │   │       └── return_rules_controller.rb
│       │   │
│       │   ├── models/                ← Models (5 files)
│       │   │   ├── merchant.rb
│       │   │   ├── product.rb
│       │   │   ├── order.rb
│       │   │   ├── return_request.rb  (with AASM)
│       │   │   ├── return_rule.rb
│       │   │   └── application_record.rb
│       │   │
│       │   ├── serializers/           ← JSON Serializers (6 files)
│       │   │   ├── merchant_serializer.rb
│       │   │   ├── product_serializer.rb
│       │   │   ├── order_serializer.rb
│       │   │   ├── return_request_serializer.rb
│       │   │   ├── return_rule_serializer.rb
│       │   │   └── active_model_serializers config
│       │   │
│       │   ├── jobs/
│       │   └── mailers/
│       │
│       ├── config/
│       │   ├── routes.rb              ← API routes (namespaced)
│       │   ├── application.rb
│       │   ├── database.yml
│       │   ├── initializers/
│       │   │   ├── cors.rb            ← CORS configuration (enabled)
│       │   │   └── ...
│       │   ├── environments/
│       │   │   ├── development.rb
│       │   │   ├── production.rb
│       │   │   └── test.rb
│       │   └── locales/
│       │
│       ├── db/
│       │   ├── migrate/               ← Migrations (5 files)
│       │   │   ├── 20260205002022_create_merchants.rb
│       │   │   ├── 20260205002601_create_products.rb
│       │   │   ├── 20260205002605_create_orders.rb
│       │   │   ├── 20260205002609_create_return_requests.rb
│       │   │   └── 20260205002611_create_return_rules.rb
│       │   ├── schema.rb              ← Generated schema
│       │   └── seeds.rb
│       │
│       ├── lib/
│       ├── bin/                       ← Executables
│       │   ├── rails
│       │   ├── rake
│       │   └── setup
│       │
│       ├── public/
│       ├── vendor/
│       ├── log/
│       ├── tmp/
│       ├── storage/
│       ├── Gemfile                    ← Dependencies (key gems added)
│       ├── Gemfile.lock
│       ├── config.ru
│       ├── Rakefile
│       ├── .ruby-version
│       ├── .gitignore
│       ├── .rubocop.yml
│       ├── README.md
│       └── Dockerfile                 ← Optional: for containerization
│
├── 🎨 FRONTEND (React)
│   └── returns-frontend/
│       ├── src/
│       │   ├── api/                   ← HTTP Client & Endpoints
│       │   │   ├── apiClient.js       (Axios with interceptors)
│       │   │   └── endpoints.js       (All API definitions)
│       │   │
│       │   ├── hooks/                 ← React Custom Hooks
│       │   │   └── useApi.js          (25+ TanStack Query hooks)
│       │   │
│       │   ├── components/
│       │   │   ├── Merchants/         ← Merchant Components
│       │   │   │   ├── MerchantList.js
│       │   │   │   ├── MerchantCard.js
│       │   │   │   └── MerchantForm.js
│       │   │   └── (More components for future iterations)
│       │   │
│       │   ├── pages/                 ← Page Components
│       │   │   └── Dashboard.js
│       │   │
│       │   ├── App.js                 ← Root component with Query Provider
│       │   ├── index.js               ← Entry point
│       │   ├── index.css              ← Tailwind CSS + global styles
│       │   └── logo.svg
│       │
│       ├── public/
│       │   ├── index.html
│       │   └── ...
│       │
│       ├── tailwind.config.js         ← Tailwind configuration
│       ├── postcss.config.js          ← PostCSS configuration
│       ├── package.json               ← Dependencies
│       ├── package-lock.json
│       ├── .gitignore
│       ├── README.md
│       └── node_modules/              (installed, not tracked)
│
├── 📁 Git Repositories
│   ├── returns-api/.git               ← Backend git repo
│   └── returns-frontend/.git          ← Frontend git repo
│
└── .gitignore (root)                  ← Excludes node_modules, etc
```

---

## File Statistics

### Backend (Rails)
```
Models:                5 files
Controllers:           6 files
Serializers:           6 files
Migrations:            5 files
Configuration Files:   5+ files
Total Ruby Files:      ~30 files
```

### Frontend (React)
```
Components:           4 files
Hooks:                1 file
API Client:           2 files
Pages:                1 file
Configuration:        2 files
Total JavaScript:     ~15 files
```

### Documentation
```
Markdown Files:       6 files
Shell Scripts:        1 file
Total Docs:          ~3,500 lines
```

---

## Key Files by Purpose

### To Understand Models
- `returns-api/app/models/merchant.rb`
- `returns-api/app/models/product.rb`
- `returns-api/app/models/order.rb`
- `returns-api/app/models/return_request.rb` (includes AASM)
- `returns-api/app/models/return_rule.rb`

### To Understand API
- `returns-api/config/routes.rb` (routes)
- `returns-api/app/controllers/api/v1/` (endpoints)
- `returns-api/app/serializers/` (JSON format)

### To Understand Database
- `returns-api/db/migrate/` (schema creation)
- `returns-api/db/schema.rb` (current schema)
- DATABASE_SCHEMA.md (visual reference)

### To Understand Frontend
- `returns-frontend/src/api/apiClient.js` (HTTP client)
- `returns-frontend/src/api/endpoints.js` (API calls)
- `returns-frontend/src/hooks/useApi.js` (data fetching)
- `returns-frontend/src/components/Merchants/` (UI)
- `returns-frontend/src/pages/Dashboard.js` (main page)

### To Understand State Machine
- `returns-api/app/models/return_request.rb` (AASM implementation)
- DATABASE_SCHEMA.md (state diagram)
- ITERATION_1.md (detailed explanation)

---

## Configuration Files

### Backend Configuration
| File | Purpose |
|------|---------|
| `Gemfile` | Ruby dependencies |
| `config/routes.rb` | API routes |
| `config/initializers/cors.rb` | CORS setup |
| `config/database.yml` | Database connection |
| `.ruby-version` | Ruby version |
| `.rubocop.yml` | Code style rules |

### Frontend Configuration
| File | Purpose |
|------|---------|
| `package.json` | npm dependencies |
| `tailwind.config.js` | Tailwind CSS setup |
| `postcss.config.js` | PostCSS setup |
| `.gitignore` | Git exclusions |

---

## Folder Purposes

### Backend (`returns-api/`)
```
app/          → Application code (models, controllers, serializers)
config/       → Configuration (routes, database, initializers)
db/           → Database (migrations, schema, seeds)
lib/          → Library code (helpers, utilities)
bin/          → Executable scripts
public/       → Static files (not used in API mode)
log/          → Application logs
tmp/          → Temporary files
storage/      → File storage
vendor/       → External dependencies
```

### Frontend (`returns-frontend/`)
```
src/          → Source code (components, pages, hooks, api)
public/       → Static files (HTML, favicon)
node_modules/ → npm dependencies (not tracked in git)
```

---

## How Files Connect

```
User Browser (localhost:3001)
         ↓
   React Components
    (src/components/)
         ↓
   Custom Hooks
    (src/hooks/useApi.js)
         ↓
   Axios Client
    (src/api/apiClient.js)
         ↓
   HTTP Request
         ↓ (CORS enabled)
   Rails Routes
    (config/routes.rb)
         ↓
   Controllers
    (app/controllers/api/v1/)
         ↓
   Models
    (app/models/)
         ↓
   PostgreSQL Database
    (migrations in db/migrate/)
         ↓
   JSON Response
    (app/serializers/)
         ↓
   Back to Browser
```

---

## File Size Reference

| Category | Approximate Size |
|----------|------------------|
| Documentation | ~60 KB |
| Backend code | ~50 KB |
| Frontend code | ~30 KB |
| node_modules | ~600 MB |
| Gemfile.lock | ~20 KB |
| Database schema | ~5 KB |

---

## Git Organization

### Backend Repository
```
returns-api/.git/
├── Initial commit with:
│   ├── All migrations
│   ├── All models
│   ├── All controllers
│   ├── All serializers
│   └── Configuration
└── Ready for branches in Iteration 2
```

### Frontend Repository
```
returns-frontend/.git/
├── Initial commit with:
│   ├── All components
│   ├── All hooks
│   ├── API client
│   └── Configuration
└── Ready for branches in Iteration 2
```

---

## Important: Files to Read in Order

1. **Start**: README.md (navigation)
2. **Then**: QUICK_START.md (setup)
3. **Next**: returns-api/app/models/*.rb (understand models)
4. **Then**: returns-api/db/migrate/*.rb (understand schema)
5. **Next**: returns-api/config/routes.rb (understand endpoints)
6. **Then**: returns-api/app/controllers/api/v1/*.rb (understand API)
7. **Next**: returns-frontend/src/api/endpoints.js (understand frontend API)
8. **Then**: returns-frontend/src/components/ (understand UI)
9. **Finally**: DATABASE_SCHEMA.md (visual reference)
10. **Review**: ITERATION_1.md (complete architecture)

---

## Files Modified from Rails Default

### Backend
- ✅ `Gemfile` - Added gems (AASM, AMS, Rack-CORS)
- ✅ `config/routes.rb` - Added API namespaced routes
- ✅ `config/initializers/cors.rb` - Enabled CORS
- ✅ Created 5 new models
- ✅ Created 6 controllers
- ✅ Created 6 serializers
- ✅ Created 5 migrations

### Frontend
- ✅ `package.json` - Added dependencies (React Query, Tailwind, Axios)
- ✅ `tailwind.config.js` - Created Tailwind config
- ✅ `postcss.config.js` - Created PostCSS config
- ✅ `src/index.css` - Added Tailwind imports
- ✅ `src/App.js` - Added Query Provider
- ✅ Created `src/api/` directory with 2 files
- ✅ Created `src/hooks/` directory with 1 file
- ✅ Created `src/components/` directory with 3 files
- ✅ Created `src/pages/` directory with 1 file

---

## Next Iteration Changes

When moving to Iteration 2, you'll be:
- ✅ Adding Service Objects in `returns-api/app/services/`
- ✅ Adding more components in `returns-frontend/src/components/`
- ✅ Adding authentication (JWT tokens)
- ✅ Creating new migrations for auth tables
- ✅ Adding tests directory structure
- ✅ Creating more hooks for additional features

---

## How to Navigate

### Find a specific model?
→ `returns-api/app/models/[name].rb`

### Find an API endpoint?
→ `returns-api/app/controllers/api/v1/[resource]_controller.rb`

### Find how data is formatted?
→ `returns-api/app/serializers/[resource]_serializer.rb`

### Find how frontend calls API?
→ `returns-frontend/src/api/endpoints.js`

### Find how frontend fetches data?
→ `returns-frontend/src/hooks/useApi.js`

### Find a React component?
→ `returns-frontend/src/components/[feature]/[Component].js`

### Find database setup?
→ `returns-api/db/migrate/[timestamp]_*.rb`

### Find complete documentation?
→ Start with README.md

---

*Last Updated: February 4, 2026*
*Smart Reverse Logistics Portal - Iteration 1*
