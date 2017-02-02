# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170202170820) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "brands", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "brands", ["name"], name: "index_brands_on_name", unique: true, using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree

  create_table "contacts", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "mobile_number"
    t.string   "landline_number"
    t.string   "email"
    t.string   "designation"
    t.integer  "customer_id"
    t.integer  "supplier_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "contacts", ["customer_id"], name: "index_contacts_on_customer_id", using: :btree
  add_index "contacts", ["supplier_id"], name: "index_contacts_on_supplier_id", using: :btree

  create_table "customers", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company_name"
    t.string   "trading_name"
    t.string   "company_reg_no"
    t.string   "company_gst_no"
    t.string   "phone"
    t.string   "fax"
    t.string   "email"
    t.string   "bill_street"
    t.string   "bill_suburb"
    t.string   "bill_city"
    t.string   "bill_state"
    t.string   "bill_postcode"
    t.string   "bill_country"
    t.string   "ship_street"
    t.string   "ship_suburb"
    t.string   "ship_city"
    t.string   "ship_state"
    t.string   "ship_postcode"
    t.string   "ship_country"
    t.integer  "payment_term"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "documents", force: :cascade do |t|
    t.integer  "customer_id"
    t.integer  "supplier_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  add_index "documents", ["customer_id"], name: "index_documents_on_customer_id", using: :btree
  add_index "documents", ["supplier_id"], name: "index_documents_on_supplier_id", using: :btree

  create_table "global_maps", force: :cascade do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "prices", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "name"
    t.integer  "price_type"
    t.decimal  "value",      precision: 8, scale: 2
    t.integer  "cond"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "product_lines", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "product_lines", ["name"], name: "index_product_lines_on_name", unique: true, using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "sku"
    t.string   "name"
    t.string   "description"
    t.decimal  "purchase_price",      precision: 8, scale: 2
    t.decimal  "selling_price",       precision: 8, scale: 2
    t.integer  "quantity"
    t.integer  "category_id"
    t.integer  "product_line_id"
    t.integer  "brand_id"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "status",                                      default: true
    t.integer  "selling_tax_id"
    t.integer  "purchase_tax_id"
    t.decimal  "selling_price_ex",    precision: 8, scale: 2
    t.decimal  "purchase_price_ex",   precision: 8, scale: 2
    t.boolean  "selling_price_type"
    t.boolean  "purchase_price_type"
    t.integer  "reorder_qty"
    t.integer  "stock_status"
    t.boolean  "removed",                                     default: false
    t.string   "barcode"
    t.integer  "warehouse_id"
    t.integer  "open_qty"
  end

  add_index "products", ["brand_id"], name: "index_products_on_brand_id", using: :btree
  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["product_line_id"], name: "index_products_on_product_line_id", using: :btree

  create_table "sales_item_activities", force: :cascade do |t|
    t.integer  "quantity"
    t.string   "activity"
    t.text     "note"
    t.integer  "sales_item_id"
    t.integer  "updated_by"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "sales_item_activities", ["sales_item_id"], name: "index_sales_item_activities_on_sales_item_id", using: :btree
  add_index "sales_item_activities", ["updated_by"], name: "index_sales_item_activities_on_updated_by", using: :btree

  create_table "sales_items", force: :cascade do |t|
    t.integer  "quantity"
    t.decimal  "unit_price",      precision: 8, scale: 2
    t.decimal  "unit_cost_price", precision: 8, scale: 2
    t.decimal  "tax_amount",      precision: 8, scale: 2
    t.decimal  "tax_rate",        precision: 8, scale: 2
    t.integer  "sales_order_id"
    t.integer  "sold_item_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.decimal  "discount_rate",   precision: 8, scale: 2
    t.decimal  "discount_amount", precision: 8, scale: 2
  end

  add_index "sales_items", ["sales_order_id"], name: "index_sales_items_on_sales_order_id", using: :btree

  create_table "sales_orders", force: :cascade do |t|
    t.string   "token"
    t.string   "status"
    t.date     "order_date"
    t.date     "shipped_at"
    t.date     "booked_at"
    t.date     "cancelled_at"
    t.text     "notes"
    t.decimal  "total_amount",       precision: 8, scale: 2
    t.string   "invoice_number"
    t.integer  "customer_id"
    t.integer  "cancelled_by_id"
    t.integer  "booked_by_id"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.date     "req_ship_date"
    t.date     "estimate_ship_date"
    t.integer  "payment_term"
    t.integer  "shipping_method_id"
    t.integer  "contact_id"
    t.string   "bill_street"
    t.string   "bill_suburb"
    t.string   "bill_city"
    t.string   "bill_state"
    t.string   "bill_postcode"
    t.string   "bill_country"
    t.string   "ship_street"
    t.string   "ship_suburb"
    t.string   "ship_city"
    t.string   "ship_state"
    t.string   "ship_postcode"
    t.string   "ship_country"
    t.string   "price_name"
  end

  add_index "sales_orders", ["customer_id"], name: "index_sales_orders_on_customer_id", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "key"
    t.string   "value"
    t.integer  "conf_type"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "shipping_methods", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stock_level_adjustments", force: :cascade do |t|
    t.string   "description"
    t.integer  "adjustment"
    t.integer  "item_id"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "stock_level_adjustments", ["item_id"], name: "index_stock_level_adjustments_on_item_id", using: :btree
  add_index "stock_level_adjustments", ["parent_type", "parent_id"], name: "index_stock_level_adjustments_on_parent_type_and_parent_id", using: :btree

  create_table "suppliers", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company_name"
    t.string   "trading_name"
    t.string   "company_reg_no"
    t.string   "company_gst_no"
    t.string   "phone"
    t.string   "fax"
    t.string   "email"
    t.string   "bill_street"
    t.string   "bill_suburb"
    t.string   "bill_city"
    t.string   "bill_state"
    t.string   "bill_postcode"
    t.string   "bill_country"
    t.string   "ship_street"
    t.string   "ship_suburb"
    t.string   "ship_city"
    t.string   "ship_state"
    t.string   "ship_postcode"
    t.string   "ship_country"
    t.integer  "payment_term"
    t.string   "bank_name"
    t.string   "bank_account_name"
    t.string   "bank_number"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "taxes", force: :cascade do |t|
    t.decimal  "rate",        precision: 5, scale: 2
    t.string   "description"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.integer  "role",                   default: 0
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "warehouses", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "contacts", "customers"
  add_foreign_key "contacts", "suppliers"
  add_foreign_key "documents", "customers"
  add_foreign_key "documents", "suppliers"
  add_foreign_key "products", "brands"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "product_lines"
  add_foreign_key "sales_item_activities", "sales_items"
  add_foreign_key "sales_items", "sales_orders"
  add_foreign_key "sales_orders", "customers"
end
