# frozen_string_literal: true

module Measurements
  # A body part measurement on a given date
  class Measurement < ApplicationRecord
    belongs_to :body_part
    belongs_to :user

    def as_json(*)
      {
        bodyPart: body_part,
        date: date,
        value: value
      }
    end
  end
end
