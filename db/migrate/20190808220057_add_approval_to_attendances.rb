class AddApprovalToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :approval, :string
  end
end
