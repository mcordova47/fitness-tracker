# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :workouts do
    get 'sessions'
  end
end
