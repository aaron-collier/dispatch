class DeploymentsController < ApplicationController
  def index
    @presenter = DeploymentsPresenter.new(period: params[:period], env: params[:env])
    @user      = UserPresenter.new
  end
end
