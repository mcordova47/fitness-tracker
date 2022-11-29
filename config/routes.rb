# frozen_string_literal: true

Rails.application.routes.draw do
  get 'workouts/:user_id/progress', to: 'workouts#progress'
  get 'workouts/:user_id/workout', to: 'workouts#workout'
  namespace :workouts do
    get 'sessions'
    get 'todays_session'
    post 'save_session'
  end
end
