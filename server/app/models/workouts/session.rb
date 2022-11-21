# frozen_string_literal: true

module Workouts
  class Session < ApplicationRecord
    has_many :exercises
  end
end
