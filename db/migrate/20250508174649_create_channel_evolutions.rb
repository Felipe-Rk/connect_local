class CreateChannelEvolutions < ActiveRecord::Migration[7.0]
  def change
    create_table :channel_evolutions do |t|
      t.string :some_field
      t.boolean :another_field

      t.timestamps
    end
  end
end
