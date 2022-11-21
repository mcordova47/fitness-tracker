# frozen_string_literal: true

module Workouts
  class Set < ApplicationRecord
    belongs_to :exercise
  end
end
