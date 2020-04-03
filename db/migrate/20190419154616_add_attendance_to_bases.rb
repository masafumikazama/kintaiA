class AddAttendanceToBases < ActiveRecord::Migration[5.1]
  def change
    add_column :bases, :attendance, :string
  end
end
