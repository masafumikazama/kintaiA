class AddFinishedOverworkAtToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :finished_overwork_at, :datetime
  end
end
