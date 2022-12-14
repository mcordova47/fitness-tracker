# frozen_string_literal: true

module Measurements
  class Measurement < ApplicationRecord
    belongs_to :body_part
    belongs_to :user
  end
end
