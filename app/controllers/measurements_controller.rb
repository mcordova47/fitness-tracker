# frozen_string_literal: true

# The controller for measurements views
class MeasurementsController < ApplicationController
  before_action do
    @user_id = params[:user_id]
    @user = User.find_by(slug: @user_id)
    next head(:not_found) unless @user

    session[:user_id] = @user_id
  end

  def progress = nil

  def measurements
    respond_to do |format|
      format.json { render json: @user.measurements.includes(:body_part).order(:date) }
    end
  end
end
