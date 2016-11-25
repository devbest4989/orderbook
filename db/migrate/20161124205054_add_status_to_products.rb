class AddStatusToProducts < ActiveRecord::Migration
  def change
	  change_table :products do |t|
	    t.attachment :image
	    t.boolean :status, :default => true
	  end  	
  end
end
