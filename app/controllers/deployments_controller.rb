class DeploymentsController < ApplicationController
  def index
    @period    = params[:period]
    @presenter = DeploymentsPresenter.new(period: @period)
    @user      = UserPresenter.new
  end
end
