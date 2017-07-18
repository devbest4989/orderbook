class CreatePaymentTerms < ActiveRecord::Migration
  def change
    create_table :payment_terms do |t|
      t.string :name
      t.integer :days
      t.integer :term_type

      t.timestamps null: false
    end
  end
end
