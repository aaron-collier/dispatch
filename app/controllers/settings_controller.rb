class SettingsController < ApplicationController
  def index
    @user = UserPresenter.new
  end
end
