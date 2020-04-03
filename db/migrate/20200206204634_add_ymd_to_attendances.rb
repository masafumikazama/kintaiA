class AddYmdToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :ymd, :date
  end
end
