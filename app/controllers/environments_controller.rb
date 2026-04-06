class EnvironmentsController < ApplicationController
  def index
    @user = UserPresenter.new
  end
end
