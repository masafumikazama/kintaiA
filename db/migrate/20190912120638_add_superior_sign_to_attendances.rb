class AddSuperiorSignToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :superior_sign, :string
  end
end
