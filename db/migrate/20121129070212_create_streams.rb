class CreateStreams < ActiveRecord::Migration
  def change
    create_table :streams do |t|
      t.string :name
      t.boolean :live
    end

    Stream.create(:name => "maximusblack", :live => false)
    Stream.create(:name => "novawar", :live => false)
  end
end
