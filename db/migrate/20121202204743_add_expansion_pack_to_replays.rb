class AddExpansionPackToReplays < ActiveRecord::Migration
  def change
    add_column :replays, :expansion_pack, :string, :default => ''
    Replay.update_all("expansion_pack = 'WoL'")
  end
end
