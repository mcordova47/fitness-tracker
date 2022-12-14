# frozen_string_literal: true

module Measurements
  class BodyPart < ApplicationRecord
    belongs_to :user

    has_many :measurements
  end
end
