class AddSlugToProduct < ActiveRecord::Migration
  def change
    add_column :products, :slug, :string
  end
end
