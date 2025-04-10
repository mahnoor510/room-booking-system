class ChangeActiveDefaultForRooms < ActiveRecord::Migration[7.2]
  def change
    change_column_default :rooms, :active, true
  end
end
