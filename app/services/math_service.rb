# frozen_string_literal: true

# Provides math utils
module MathService
  def self.factorial(num)
    ans = 1

    (1..num).each do |i|
      ans *= i
    end

    ans
  end
end
