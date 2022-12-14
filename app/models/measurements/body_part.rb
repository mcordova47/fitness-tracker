# frozen_string_literal: true

module Measurements
  # A part of the body to be measured
  class BodyPart < ApplicationRecord
    belongs_to :user

    has_many :measurements

    def as_json(*)
      {
        name: name
      }
    end
  end
end
