# frozen_string_literal: true

# The controller for top-level views
class MainController < ApplicationController
  def landing = (redirect_to workouts_progress_path(user_id: session[:user_id]) if session[:user_id])

  def workout = redirect_to(workouts_workout_path(user_id: User.create!.slug))
end
