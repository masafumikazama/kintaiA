class AddSuperiorApprovalToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :superior_approval, :string
  end
end
