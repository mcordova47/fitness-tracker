# frozen_string_literal: true

# The controller for workouts
class WorkoutsController < ApplicationController
  def sessions
    user = User.find_by(slug: params[:slug])
    return head(:not_found) unless user

    respond_to do |format|
      format.json { render json: user.workout_sessions.order(:date) }
    end
  end
end
