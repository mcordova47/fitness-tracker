# frozen_string_literal: true

# The controller for workouts
class WorkoutsController < ApplicationController
  def sessions
    user = User.find_by(slug: params[:slug])
    return head(:not_found) unless user

    workout_sessions = user.workout_sessions.map(&:to_client_json)

    respond_to do |format|
      format.json { render json: workout_sessions }
    end
  end
end
