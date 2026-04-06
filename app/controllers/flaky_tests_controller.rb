class FlakyTestsController < ApplicationController
  def index
    @user = UserPresenter.new
  end
end
