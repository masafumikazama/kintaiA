class AttendancesController < ApplicationController
  
  protect_from_forgery
    
  def create
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find_by(worked_on: Date.today)
    if @attendance.started_at.nil?
      @attendance.update_attributes(started_at: current_time)
      flash[:info] = 'おはようございます。'
    elsif @attendance.finished_at.nil?
      @attendance.update_attributes(finished_at: current_time)
      flash[:info] = 'おつかれさまでした。'
    else
      flash[:danger] = 'トラブルがあり、登録出来ませんでした。'
    end
    redirect_to @user
  end    
  
  def edit
    @user = User.find(params[:id])
    @first_day = Date.parse(params[:date])
    @last_day = @first_day.end_of_month
    @dates = @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
    
  end
  
  def update
    @user = User.find(params[:id])
    if attendances_invalid?
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes(item)
      end
      flash[:success] = '勤怠情報を更新しました。'
      redirect_to user_path(@user, params:{first_day: params[:date]})
    else
      flash[:danger] = "不正な時間入力がありました、再入力してください。"
      redirect_to edit_attendances_path(@user, params[:date])
    end
  end
  
  def update_edit_attendance
    @user = User.find(params[:id])
    if attendances_invalid?
     attendances_params.each do |id,item|
        attendance = Attendance.find(id)
        attendance.update_attributes(item)
     end  
      flash[:success] = "勤怠情報を更新しました。"
      redirect_to @user
     else
      flash[:danger] = "不正な時間入力がありました、再入力してください。"
      redirect_to edit_attendances_path(@user, params[:date])
     end
  end
  
  def working
    @users = User.all.includes(:attendances)
    
    
  end 
  
  def approval_histories
    @user = User.find(params[:id])
    @first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month
    (@first_day..@last_day).each do |day|
      unless @user.attendances.any? {|attendance| attendance.worked_on == day}
        record = @user.attendances.build(worked_on: day)
        record.save
      end
    end
    @dates = @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
    
    @attendance = @user.attendances.find_by(params[:id])
    
    
    @attendances = @user.attendances.where.not(note: nil)
    
  end
  
  def edit_overwork_request
    @day = Date.parse(params[:day])
    @youbi = params[:youbi]
    @user = User.find(params[:id])
    @attendance = @user.attendances.find_by(worked_on: @day)
    redirect_to(root_url) unless current_user?(@user)
    @first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month
    (@first_day..@last_day).each do |day|
      unless @user.attendances.any? {|attendance| attendance.worked_on == day}
        record = @user.attendances.build(worked_on: day)
        record.save
      end
    end
    @dates = @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
    @attendances = @user.attendances.where.not(work_process: nil)
    
  end

  def update_overwork_request
    @user = User.find(params[:id])
    @day = Date.parse(params[:day])
    @attendance = @user.attendances.find_by(worked_on: @day)
    if @attendance.update_attributes(overwork_request_params)
    end  
       flash[:success] = "残業を申請しました。"
       redirect_to user_url  
  end
  
  def edit_overwork_approval
    @user = User.find(params[:id])
    
    redirect_to(root_url) unless current_user?(@user)
    @first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month
    (@first_day..@last_day).each do |day|
      unless @user.attendances.any? {|attendance| attendance.worked_on == day}
        record = @user.attendances.build(worked_on: day)
        record.save
      end
    end
    @dates = @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
    
    @attendance = @user.attendances.find_by(params[:id])
    
    if @user.id == 2
      @users = Attendance.where(id: User.where(name: @user.name).select(:user_id))

      @attendances = Attendance.where.not(superior_select: nil).where("change is null or change = ?", 2).where(superior_select: "2")
      
    elsif @user.id == 3
      @users = Attendance.where(id: User.where(name: @user.name).select(:user_id))

      @attendances = Attendance.where.not(superior_select: nil).where("change is null or change = ?", 2).where(superior_select: "3")
    
    end
  end
  
  def update_overwork_approval
    @user = User.find(params[:id])
    
    
     attendance_params.each do |id, item|
       attendance = Attendance.find(id)
       attendance.update_attributes(item)
    
       flash[:success] = "残業を申請しました。"
      
     end
     redirect_to user_url 
    
  end  
  
  def edit_attendance_approval
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
    @first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month
    (@first_day..@last_day).each do |day|
      unless @user.attendances.any? {|attendance| attendance.worked_on == day}
        record = @user.attendances.build(worked_on: day)
        record.save
      end
    end
    @dates = @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
    
    @attendance = @user.attendances.find_by(params[:id])
    
    if @user.id == 2
      
     @users = Attendance.where(id: User.where(name: @user.name).select(:user_id))
     @attendances = Attendance.where.not(superior_sign: nil).where.not(started_edit: nil).where.not(finished_edit: nil).where("change_attendance is null or change_attendance = ?", 2).where(superior_sign: "2")
    
    elsif @user.id == 3
    
     @users = Attendance.where(id: User.where(name: @user.name).select(:user_id))
     @attendances = Attendance.where.not(superior_sign: nil).where.not(started_edit: nil).where.not(finished_edit: nil).where("change_attendance is null or change_attendance = ?", 2).where(superior_sign: "3")
    end
  end
  
  def update_attendance_approval
    @user = User.find(params[:id])
    
    
     change_attendance_params.each do |id, item|
       attendance = Attendance.find(id)
       attendance.update_attributes(item)
    
       flash[:success] = "残業を申請しました。"
      
     end
     
     
     redirect_to user_url 
    
  end
  
  def edit_superior_approval
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
    @first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month
    (@first_day..@last_day).each do |day|
      unless @user.attendances.any? {|attendance| attendance.worked_on == day}
        record = @user.attendances.build(worked_on: day)
        record.save
      end
    end
    @dates = @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
    
    @attendance = @user.attendances.find_by(params[:id])
    
    if @user.id == 2
     @users = Attendance.where(id: User.where(name: @user.name).select(:user_id))
     
     @attendances = Attendance.where.not(superior_approval: nil).where("change_edit is null or change_edit = ?", 2).where(superior_approval: "2").where(worked_on: @first_day)
     
    elsif @user.id == 3
     @users = Attendance.where(id: User.where(name: @user.name).select(:user_id))
     @attendances = Attendance.where.not(superior_approval: nil).where("change_edit is null or change_edit = ?", 2).where(superior_approval: "3")
    end 
  end
  
  def update_superior_approval
    @user = User.find(params[:id])
    
    
     superior_attendance_params.each do |id, item|
       attendance = Attendance.find(id)
       attendance.update_attributes(item)
    
       flash[:success] = "一か月分の勤怠を更新しました。"
      
     end
     redirect_to user_url 
  end  
  
  def approval_histories
    @user = User.find(params[:id])
    @first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month
    (@first_day..@last_day).each do |day|
      unless @user.attendances.any? {|attendance| attendance.worked_on == day}
        record = @user.attendances.build(worked_on: day)
        record.save
      end
    end
    @dates = @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
    
    @fday = Date.parse(params["ymd(1i)"].to_s+"-"+params["ymd(2i)"].to_s+"-"+"01" )
    @lday = @fday.end_of_month
    (@fday..@lday).each do |day|
      unless @user.attendances.any? {|attendance| attendance.ymd == day}
        record = @user.attendances.build(ymd: day)
        record.save
      end
    end
    
    @superior = User.find_by(id: 2)
    
    @attendance = @user.attendances.find_by(params[:id])
    
    
    @attendances = @user.attendances.where(worked_on: @fday..@lday).where.not(change_attendance: nil).where(approval: "勤怠編集承認")
    
    
  end
  
  def show_approval_histories
    @user = User.find(params[:id])
    
    
     ymd_params.each do |id, item|
       attendance = Attendance.find(id)
       attendance.update_attributes(item)
    
       flash[:success] = "残業を申請しました。"
      
     end
     redirect_to user_url 
  end
  
  def month_approval
    @user = User.find(params[:id])
    @first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month
    @attendances = @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
    
    
      
    if  @attendances.each do |attendance| 
      attendance.update_attributes(approvals_params)
    end
     flash[:success] = "一か月分の勤怠を申請しました。"
      redirect_to @user
      
    else
      flash[:danger] = "不正な時間入力がありました、再入力してください。"
      redirect_to @user
      
      
    
    end
  end
  
  private
  
    def attendances_params
      params.permit(attendances: [:started_edit, :finished_edit, :note, :next_day, :superior_sign])[:attendances]
    end
    
    def overwork_request_params
      params.require(:attendance).permit(:next_day, :approval)
    end
    
    def attendance_params
      params.require(:user).permit(attendances: [:overwork_approval, :change])[:attendances]
    end
    
    def change_attendance_params
      params.require(:user).permit(attendances: [:approval, :change_attendance, :approval_date])[:attendances]
    end
    
    def superior_attendance_params
      params.require(:user).permit(attendances: [:month_approval, :change_edit])[:attendances]
    end
    
    def ymd_params
      params.require(:user).permit(attendances: [:ymd])[:attendances]
    end
    
    def approvals_params
      params.require(:user).permit(:superior_approval)
    end
end
