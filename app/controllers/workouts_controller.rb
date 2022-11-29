# frozen_string_literal: true

# The controller for the workouts API
class WorkoutsController < ApplicationController
  before_action only: %i[progress workout] do
    @user_id = params[:user_id]
  end

  def progress; end

  def workout; end

  def sessions
    user = User.find_by(slug: params[:user_id])
    return head(:not_found) unless user

    respond_to do |format|
      format.json { render json: user.workout_sessions.order(:date) }
    end
  end

  def todays_session
    user = User.find_by(slug: params[:user_id])
    return head(:not_found) unless user

    session = user.workout_sessions.find_by(date: Time.zone.today)
    respond_to do |format|
      format.json { render json: session }
    end
  end

  def save_session
    user = User.find_by(slug: params[:user_id])
    return head(:not_found) unless user

    session = user.workout_sessions.create!(date: Time.zone.today, muscle_group: params[:muscle_group])
    respond_to do |format|
      format.json { render json: session }
    end
  end
end
