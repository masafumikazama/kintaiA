class AddFinishedEditToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :finished_edit, :datetime
  end
end
