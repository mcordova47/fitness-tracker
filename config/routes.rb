# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'main#landing'
  namespace :main, path: '/' do
    get 'workout'
  end

  namespace :workouts, path: ':user_id/workouts' do
    get 'progress'
    get 'workout'
    get 'sessions'
    get 'todays_session'
    get 'last_session'
    get 'last_exercise'
    post 'create_session'
    post 'create_exercise'
    post 'add_set'
    post 'update_set'
    post 'copy_exercises_to_today'
    post 'delete_exercise'
  end
end
