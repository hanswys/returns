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

ActiveRecord::Schema[8.1].define(version: 2026_02_05_034538) do
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
    t.datetime "created_at", null: false
    t.bigint "merchant_id", null: false
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.text "reason", null: false
    t.datetime "requested_date", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "orders", "merchants"
  add_foreign_key "products", "merchants"
  add_foreign_key "return_requests", "merchants"
  add_foreign_key "return_requests", "orders"
  add_foreign_key "return_requests", "products"
  add_foreign_key "return_rules", "merchants"
  add_foreign_key "return_rules", "products"
end
