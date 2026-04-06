class UpdatesController < ApplicationController
  def index
    @user = UserPresenter.new
  end
end
