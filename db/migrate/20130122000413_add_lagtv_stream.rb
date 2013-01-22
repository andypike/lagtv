class AddLagtvStream < ActiveRecord::Migration
  def change
    Stream.create(:name => "lagtv", :live => false)
  end
end
