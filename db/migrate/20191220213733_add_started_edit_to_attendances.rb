class AddStartedEditToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :started_edit, :datetime
  end
end
