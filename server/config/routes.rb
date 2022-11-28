# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :workouts do
    get 'sessions'
    get 'todays_session'
    post 'save_session'
  end
end
