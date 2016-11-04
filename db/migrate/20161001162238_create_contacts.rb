class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :first_name
      t.string :last_name
      t.string :mobile_number
      t.string :landline_number
      t.string :email
      t.string :designation
      t.references :customer, index: true, foreign_key: true
      t.references :supplier, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
