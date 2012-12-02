class AddExpansionPackToReplays < ActiveRecord::Migration
  def change
    add_column :replays, :expansion_pack, :string, :default => 'WoL'
  end
end
