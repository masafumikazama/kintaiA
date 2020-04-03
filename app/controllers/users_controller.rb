class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index,:edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:index, :destroy, :edit_basic_info, :update_basic_info]
  
  def index
    @users = User.paginate(page: params[:page])
    @user = User.find_by(params[:id])
  end
  
  def import
    # fileはtmpに自動で一時保存される
    User.import(params[:file])
    redirect_to users_url
  end
  
  def export
    @user = User.find(params[:id])
    @attendance = @user.attendances.find_by(params[:id])
    @first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month
    (@first_day..@last_day).each do |day|
      unless @user.attendances.any? {|attendance| attendance.worked_on == day}
        record = @user.attendances.build(worked_on: day)
        record.save
      end
    end
    @dates = user_attendances_month_date
    respond_to do |format|
      format.html do
          #html用の処理を書く
      end 
      format.csv do
          #csv用の処理を書く
      end
    end
  end
  
  def show
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
    @dates = user_attendances_month_date
    @worked_sum = @dates.where.not(started_at: nil).count
    
    if @user.id == 2
     @count = Attendance.where.not(superior_select: nil).where("change is null or change = ?", 2).where(superior_select: "2")
    elsif @user.id == 3 
     @count = Attendance.where.not(superior_select: nil).where("change is null or change = ?", 2).where(superior_select: "3")
    end 
    
    if @user.id == 2
     @count_a = Attendance.where.not(superior_sign: nil).where.not(started_edit: nil).where.not(finished_edit: nil).where("change_attendance is null or change_attendance = ?", 2).where(superior_sign: "2")
    elsif @user.id == 3 
     @count_a = Attendance.where.not(superior_sign: nil).where.not(started_edit: nil).where.not(finished_edit: nil).where("change_attendance is null or change_attendance = ?", 2).where(superior_sign: "3")
    end
    
    if @user.id == 2
     @count_b = Attendance.where.not(superior_approval: nil).where("change_edit is null or change_edit = ?", 2).where(superior_approval: "2").where(worked_on: @first_day)
    elsif @user.id == 3 
     @count_b = Attendance.where.not(superior_approval: nil).where("change_edit is null or change_edit = ?", 2).where(superior_approval: "3").where(worked_on: @first_day)
    end
    
    @attendance = @user.attendances.find_by(params[:id])
    @attendances = Attendance.where(id: User.where(id: @user.id))
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "ユーザーの新規作成に成功しました。"
      redirect_to @user
    else
      render 'new'
    end
  end
  
  def edit
   
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render 'edit'
    end
  end  
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
    @user = User.find(params[:id])
  end
  
  def update_basic_info
    @user = User.find(params[:id])
    if @user.update_attributes(basic_info_params)
      flash[:success] = "基本情報を更新しました。"
      redirect_to @user
    else
      render 'edit_basic_info'
    end
  end
  
  def edit_user_info
     @users = User.where(id: 2..Float::INFINITY).paginate(page: params[:page])
     @user = User.find_by(params[:id])
  end
  
  def update_user_info
  @user = User.find(params[:id])
  if @user.update_attributes(user_info_params)
    flash[:success] = "基本情報を更新しました。"
    redirect_to @user   
  else
    redirect_to users_url
  end
  end

  
  def working
    @users = Attendance.where.not(started_at: nil).where(finished_at: nil, worked_on: Date.today)
    @attendances = Attendance.where.not(started_at: nil).where(finished_at: nil, worked_on: Date.today)
    @user = User.find_by(params[:id])
    @first_day = Date.today.beginning_of_month
  @last_day = @first_day.end_of_month
  (@first_day..@last_day).each do |day|
    unless @user.attendances.any? {|attendance| attendance.worked_on == day}
      record = @user.attendances.build(worked_on: day)
      record.save
    end
  end
    @dates = user_attendances_month_date
    @attendance = @user.attendances.find_by(worked_on: Date.today)
    if @attendance.started_at.nil?
      @attendance.update_attributes(started_at: current_time)
    end  
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
    @dates = user_attendances_month_date
    @worked_sum = @dates.where.not(started_at: nil).count
    
  end

  def update_overwork_request
    @user = User.find(params[:id])
    @day = Date.parse(params[:day])
    @attendance = @user.attendances.find_by(worked_on: @day)
    if @attendance.update_attributes(overwork_request_params)
       flash[:success] = "残業を申請しました。"
       redirect_to user_url
    elsif params[:next_day] == true
       
    
       redirect_to user_url
       
    else
       redirect_to user_url  
    end    
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
    
    @users = Attendance.where.not(work_process: nil)
    @attendances = Attendance.where.not(work_process: nil)
    
  end

  def update_overwork_approval
    @user = User.find(params[:id])
    
    @attendance = @user.attendances.find_by(params[:id])
    if @attendance.update_attributes(overwork_approval_params)
    
       flash[:success] = "残業を申請しました。"
       redirect_to user_url  
    end
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
    
    @users = Attendance.where.not(note: nil)
    @attendances = @user.attendances.where.not(note: nil)
    
  end
  
  def update_attendance_approval
    
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
    
    
    @attendances = @user.attendances.where.not(superior_approval: nil)
    
  end
  
  def update_superior_approval
    @user = User.find(params[:id])
    @attendance = @user.attendances.find_by(params[:id])
    if @attendance.update_attributes(superior_approval_params)
      flash[:success] = "一か月分の勤怠を申請しました。"
      redirect_to @user
    
    end
  end  
  
  def month_approval
    @user = User.find(params[:id])
    @attendance = @user.attendances.find_by(params[:id])
    if approval_invalid?
      month_approval_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes(item)
     end
     flash[:success] = "一か月分の勤怠を申請しました。"
      redirect_to @user
      
    else
      flash[:danger] = "不正な時間入力がありました、再入力してください。"
      redirect_to @user
      
      
    
    end
  end
  
  def confirm
    @user = User.find(params[:id])
    
    @first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month
    (@first_day..@last_day).each do |day|
      unless @user.attendances.any? {|attendance| attendance.worked_on == day}
        record = @user.attendances.build(worked_on: day)
        record.save
      end
    end
    @dates = user_attendances_month_date
    @worked_sum = @dates.where.not(started_at: nil).count
    @count = Attendance.where.not(superior: nil)
    @count_a = Attendance.where.not(superior_sign: nil)
    @count_b = Attendance.where.not(superior_approval: nil)
    @attendance = @user.attendances.find_by(params[:id])
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
    
    @fday = first_day(params[:first_day])
    @lday = @fday.end_of_month
    (@fday..@lday).each do |day|
      unless @user.attendances.any? {|attendance| attendance.ymd == day}
        record = @user.attendances.build(ymd: day)
        record.save
      end
    end
    
    @attendance = @user.attendances.find_by(params[:id])
    
    @attendances = @user.attendances.where.not(superior_approval: nil).where(worked_on: @first_day..@last_day)
    
    
    
  end
  
  def show_approval_histories
    @user = User.find(params[:id])
    @attendance = @user.attendances.find_by(params[:id])
    if @attendance.update_attributes(ymd_params)
     flash[:success] = "一か月分の勤怠を申請しました。"
      redirect_to @user
    else  
      flash[:danger] = "不正な時間入力がありました、再入力してください。"
      redirect_to @user
    end
  end  
  
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation,:employee_number, :uid, :basic_work_time, :designated_work_start_time, :designated_work_end_time )
    end
    
    def basic_info_params
      params.require(:user).permit(:basic_time, :work_time)
    end
    
    def user_info_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation,:employee_number, :uid, :basic_work_time, :designated_work_start_time, :designated_work_end_time )
    end
    
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
      end
    end
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
    def overwork_request_params
      params.require(:attendance).permit(:finished_overwork_at, :next_day, :work_process, :superior_select)
    end
    
    def overwork_approval_params
      params.require(:user).permit(attendances: [:overwork_approval, :change])[:attendances]
      
    end
    
    def superior_approval_params
      params.require(:attendance).permit(:month_approval, :change_edit)
    end
    
    def month_approval_params
      params.require(:attendance).permit(:superior_approval)
    end
    
    def ymd_params
      params.require(:attendance).permit(:ymd)
    end  
end
