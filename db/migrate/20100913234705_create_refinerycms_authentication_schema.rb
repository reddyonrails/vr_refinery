class CreateRefinerycmsAuthenticationSchema < ActiveRecord::Migration
  def self.up
    # Postgres apparently requires the roles_admins table to exist before creating the roles table.
    create_table ::RolesAdmins.table_name, :id => false, :force => true do |t|
      t.integer "admin_id"
      t.integer "role_id"
    end unless ::RolesAdmins.table_exists?

    create_table ::Role.table_name, :force => true do |t|
      t.string "title"
    end unless ::Role.table_exists?

    unless ::AdminPlugin.table_exists?
      create_table ::AdminPlugin.table_name, :force => true do |t|
        t.integer "admin_id"
        t.string  "name"
        t.integer "position"
      end

      add_index ::AdminPlugin.table_name, ["name"], :name => "index_#{::AdminPlugin.table_name}_on_title"
      add_index ::AdminPlugin.table_name, ["admin_id", "name"], :name => "index_unique_#{::AdminPlugin.table_name}", :unique => true

    end

    unless ::Admin.table_exists?
      create_table ::Admin.table_name, :force => true do |t|
        t.string   "login",             :null => false
        t.string   "email",             :null => false
        t.string   "crypted_password",  :null => false
        t.string   "password_salt",     :null => false
        t.string   "persistence_token"
        t.datetime "created_at"
        t.datetime "updated_at"
        t.string   "perishable_token"
      end

      add_index ::Admin.table_name, ["id"], :name => "index_#{::Admin.table_name}_on_id"
    end
  end

  def self.down
    [::Admin].reject{|m|
      !(defined?(m) and m.respond_to?(:table_name))
    }.each do |model|
      drop_table model.table_name if model.table_exists? if model.table_exists?
    end
  end
end
