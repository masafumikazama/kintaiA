class AddChangeAttendanceToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_attendance, :integer
  end
end
