class AddPaymentModeToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :payment_mode, :integer
    add_column :payments, :reference_no, :string
    add_column :payments, :note, :string
  end
end
