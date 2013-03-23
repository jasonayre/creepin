class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.integer :brand_id
      t.integer :category_id

      t.timestamps
    end
    add_index :products, :brand_id
    add_index :products, :category_id
  end
end
