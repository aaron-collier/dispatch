class PrMonitorController < ApplicationController
  def index
    @user = UserPresenter.new
  end
end
