class SimplifyEmailModelRoles < ActiveRecord::Migration
  def up
    add_column :emails, :role, :string
    remove_column :emails, :member
    remove_column :emails, :analyst
    remove_column :emails, :dev_team
    remove_column :emails, :moderator
    remove_column :emails, :community_manager
    remove_column :emails, :admin
  end

  def down
    remove_column :emails, :role
    add_column :emails, :member, :boolean
    add_column :emails, :analyst, :boolean
    add_column :emails, :dev_team, :boolean
    add_column :emails, :moderator, :boolean
    add_column :emails, :community_manager, :boolean
    add_column :emails, :admin, :boolean
  end
end
