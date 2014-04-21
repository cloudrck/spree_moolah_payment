class SpreeMoolahCheckouts < ActiveRecord::Migration
	def change
		create_table :spree_moolah_checkouts do |t|
			t.string :order_id
			t.string :status
			t.string :transaction_id
			t.timestamps
		end
	end
end
