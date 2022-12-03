# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :workouts, path: ':user_id/workouts' do
    get 'progress'
    get 'workout'
    get 'sessions'
    get 'todays_session'
    post 'create_session'
    post 'create_exercise'
    post 'add_set'
    post 'update_set'
  end
end
