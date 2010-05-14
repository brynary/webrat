ActiveRecord::Schema.define(:version => 0) do
  create_table :albums, :force => true do |t|
    t.string :name
  end

  create_table :photos, :force => true do |t|
    t.string :image
    t.integer :album_id
  end
end
