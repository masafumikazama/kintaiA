class BasesController < ApplicationController
  
  def show
    @base = Base.new
    @bases = Base.all
  end
  
  
  
  
  def create
    @base = Base.new(base_params)
    if @base.save
     redirect_to bases_url
    else
      render 'new'
    end  
  end
  
  def update
    @base = Base.find(params[:id])
    if @base.update_attributes(base_params)
      redirect_to bases_url
    end
  end
  
  def destroy
    @base = Base.find(params[:id]).destroy
    flash[:success] = "削除しました。"
    redirect_to bases_url
  end
  
  private

    def base_params
      params.require(:base).permit(:name, :number, :attendance)
    end
end
