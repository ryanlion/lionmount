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

ActiveRecord::Schema.define(version: 20150421220558) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "order_items", force: true do |t|
    t.string   "order_id"
    t.string   "itemUUID"
    t.string   "product_code"
    t.string   "product_name"
    t.string   "sorting"
    t.string   "image_uid"
    t.string   "title"
    t.string   "weight_per_product"
    t.string   "color"
    t.string   "spec"
    t.string   "discount"
    t.string   "quantity_per_unit"
    t.string   "item_price"
    t.string   "single_unit"
    t.string   "unit"
    t.string   "no_of_unit"
    t.string   "volume_per_unit"
    t.string   "item_total_weight"
    t.string   "weight_per_unit"
    t.string   "item_total_price"
    t.string   "item_total_volume"
    t.string   "remarks"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree

  create_table "orders", force: true do |t|
    t.string   "customer_id"
    t.string   "supplier_name"
    t.string   "total_weight"
    t.string   "total_volume"
    t.string   "total_price"
    t.string   "supplier_english_name"
    t.string   "supplier_address"
    t.string   "supplier_contact_person"
    t.string   "supplier_contact_no"
    t.string   "supplier_email"
    t.string   "deposit"
    t.string   "marks"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relation_shipment_orders", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipment_order_relations", force: true do |t|
    t.string   "order_id"
    t.string   "shipment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shipment_order_relations", ["order_id"], name: "index_shipment_order_relations_on_order_id", using: :btree
  add_index "shipment_order_relations", ["shipment_id"], name: "index_shipment_order_relations_on_shipment_id", using: :btree

  create_table "shipments", force: true do |t|
    t.string   "shipment_uuid"
    t.string   "description"
    t.string   "status"
    t.string   "customer_name"
    t.string   "marks"
    t.string   "port_dispatch"
    t.string   "port_distination"
    t.string   "doc_date"
    t.string   "loading_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "role"
    t.string   "name"
    t.string   "address"
    t.string   "fax"
    t.string   "contact_no"
    t.string   "company_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
