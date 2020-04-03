class AddOverworkApprovalToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_approval, :string
  end
end
