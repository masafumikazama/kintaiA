require 'csv'

CSV.generate do |csv|
  column_names = %w(日付　出社　退社)
  csv << column_names
  @dates.each do |day|
    column_values = [
      day.worked_on.to_s(:date),
      day.started_at && day.started_at.to_s(:time),
      day.finished_at && day.finished_at.to_s(:time)
    ]
    csv << column_values
  end
end