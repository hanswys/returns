# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_07_184251) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "merchants", force: :cascade do |t|
    t.text "address"
    t.string "contact_person"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_merchants_on_email", unique: true
    t.index ["status"], name: "index_merchants_on_status"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "customer_email", null: false
    t.string "customer_name", null: false
    t.bigint "merchant_id", null: false
    t.datetime "order_date", null: false
    t.string "order_number", null: false
    t.integer "status", default: 0, null: false
    t.decimal "total_amount", precision: 12, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["customer_email"], name: "index_orders_on_customer_email"
    t.index ["merchant_id", "order_number"], name: "index_orders_on_merchant_id_and_order_number", unique: true
    t.index ["merchant_id"], name: "index_orders_on_merchant_id"
    t.index ["status"], name: "index_orders_on_status"
  end

  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "merchant_id", null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "sku", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id", "sku"], name: "index_products_on_merchant_id_and_sku", unique: true
    t.index ["merchant_id"], name: "index_products_on_merchant_id"
  end

  create_table "return_requests", force: :cascade do |t|
    t.string "carrier"
    t.datetime "created_at", null: false
    t.string "idempotency_key"
    t.text "label_generation_error"
    t.datetime "label_generation_failed_at"
    t.string "label_url"
    t.bigint "merchant_id", null: false
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.text "reason", null: false
    t.datetime "requested_date", null: false
    t.integer "status", default: 0, null: false
    t.string "tracking_number"
    t.datetime "updated_at", null: false
    t.index ["idempotency_key"], name: "index_return_requests_on_idempotency_key", unique: true
    t.index ["merchant_id"], name: "index_return_requests_on_merchant_id"
    t.index ["order_id", "product_id"], name: "index_return_requests_on_order_id_and_product_id", unique: true
    t.index ["order_id"], name: "index_return_requests_on_order_id"
    t.index ["product_id"], name: "index_return_requests_on_product_id"
    t.index ["status"], name: "index_return_requests_on_status"
  end

  create_table "return_rules", force: :cascade do |t|
    t.jsonb "configuration", default: {}, null: false
    t.datetime "created_at", null: false
    t.bigint "merchant_id", null: false
    t.bigint "product_id"
    t.datetime "updated_at", null: false
    t.index ["configuration"], name: "index_return_rules_on_configuration", using: :gin
    t.index ["merchant_id", "product_id"], name: "index_return_rules_on_merchant_id_and_product_id", unique: true
    t.index ["merchant_id"], name: "index_return_rules_on_merchant_id"
    t.index ["product_id"], name: "index_return_rules_on_product_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil, null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "error"
    t.bigint "job_id", null: false
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "finished_at", precision: nil
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "queue_name", null: false
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", precision: nil, null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", precision: nil, null: false
    t.string "task_key", null: false
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", precision: nil, null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", precision: nil, null: false
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil, null: false
    t.string "key", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "value", default: 1, null: false
  end

  create_table "status_audit_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event"
    t.string "from_status"
    t.text "metadata"
    t.bigint "return_request_id", null: false
    t.string "to_status"
    t.string "triggered_by"
    t.datetime "updated_at", null: false
    t.index ["return_request_id"], name: "index_status_audit_logs_on_return_request_id"
  end

  add_foreign_key "orders", "merchants"
  add_foreign_key "products", "merchants"
  add_foreign_key "return_requests", "merchants"
  add_foreign_key "return_requests", "orders"
  add_foreign_key "return_requests", "products"
  add_foreign_key "return_rules", "merchants"
  add_foreign_key "return_rules", "products"
  add_foreign_key "status_audit_logs", "return_requests"
end
