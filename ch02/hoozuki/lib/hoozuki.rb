# frozen_string_literal: true

class Hoozuki
  def initialize(pattern)
    @pattern = pattern
  end

  def match?(input)
    @pattern == input
  end
end
