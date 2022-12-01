# frozen_string_literal: true

# The controller for the workouts API
class WorkoutsController < ApplicationController
  before_action only: %i[progress workout] do
    @user_id = params[:user_id]
  end

  def progress; end

  def workout
    user = User.find_by(slug: @user_id)
    return head(:not_found) unless user

    @muscle_groups = user.muscle_groups.order(:name)
    @exercise_kinds = user.exercise_kinds.order(:kind)
  end

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

    muscle_group = user.muscle_groups.find_or_create_by!(name: params[:muscle_group])
    session = user.workout_sessions.create!(date: Time.zone.today, muscle_group: muscle_group)
    respond_to do |format|
      format.json { render json: session }
    end
  end

  def create_exercise_kind # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    user = User.find_by(slug: params[:user_id])
    return head(:not_found) unless user

    exercise_kind = user.exercise_kinds.find_or_create_by!(kind: params[:exercise_kind])
    user
      .workout_sessions
      .find_by(date: Time.zone.today)
      .exercises
      .create!(exercise_kind: exercise_kind)

    respond_to do |format|
      format.json { render json: nil }
    end
  end
end
