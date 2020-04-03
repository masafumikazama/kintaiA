module UsersHelper
    
  def format_basic_time(datetime)
    format("%.2f", ((datetime.hour * 60) + datetime.min)/60.0)
  end  
  
  def format_overwork_time(datetime)
    if next_day = "true"
     format("%.2f", ((datetime.hour * 60) + datetime.min)/60.0 - 24)
    else
     format("%.2f", ((datetime.hour * 60) + datetime.min)/60.0 - 24)
    end 
  end
  
  def approval_invalid?
    attendances = true
    attendances_params.each do |id, item|
      if item[:superior_approval].blank?
        attendances = false
        break
      end
    end
  end
  
end
