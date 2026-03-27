class DashboardController < ApplicationController
  def index
    @presenter = DashboardPresenter.new
    @user = UserPresenter.new
  end
end
