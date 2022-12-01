# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :workouts, path: ':user_id/workouts' do
    get 'progress'
    get 'workout'
    get 'sessions'
    get 'todays_session'
    post 'save_session'
    post 'create_exercise_kind'
  end
end
