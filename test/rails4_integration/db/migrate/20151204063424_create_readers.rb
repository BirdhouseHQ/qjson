class CreateReaders < ActiveRecord::Migration
  def change
    create_table :readers do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :books_readers , id: false do |t|
      t.references :book
      t.references :reader
    end
  end
end
