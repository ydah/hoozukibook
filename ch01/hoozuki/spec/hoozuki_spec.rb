# frozen_string_literal: true

require_relative '../lib/hoozuki'

RSpec.describe Hoozuki do
  describe '#initialize' do
    it 'accepts a pattern string' do
      expect { Hoozuki.new('abc') }.not_to raise_error
    end
  end
end
