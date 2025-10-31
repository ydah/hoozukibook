# frozen_string_literal: true

require_relative '../lib/hoozuki'

RSpec.describe Hoozuki do
  describe '#match?' do
    context 'with exact match pattern' do
      let(:regex) { Hoozuki.new('abc') }

      it 'matches exact string' do
        expect(regex.match?('abc')).to be true
      end

      it 'does not match shorter string' do
        expect(regex.match?('ab')).to be false
      end

      it 'does not match longer string' do
        expect(regex.match?('abcd')).to be false
      end

      it 'matches empty string' do
        regex = Hoozuki.new('')
        expect(regex.match?('')).to be true
      end

      it 'does not match empty pattern with non-empty input' do
        regex = Hoozuki.new('')
        expect(regex.match?('a')).to be false
      end

      it 'matches multibyte characters' do
        regex = Hoozuki.new('こんにちは')
        expect(regex.match?('こんにちは')).to be true
        expect(regex.match?('さようなら')).to be false
      end
    end

    context 'with choice pattern' do
      let(:regex) { Hoozuki.new('a|b') }

      it 'matches first choice' do
        expect(regex.match?('a')).to be true
      end

      it 'matches second choice' do
        expect(regex.match?('b')).to be true
      end

      it 'does not match both choices concatenated' do
        expect(regex.match?('ab')).to be false
      end

      it 'does not match neither choice' do
        expect(regex.match?('c')).to be false
      end
    end

    context 'with complex choice pattern' do
      let(:regex) { Hoozuki.new('cat|dog') }

      it 'matches first choice' do
        expect(regex.match?('cat')).to be true
      end

      it 'matches second choice' do
        expect(regex.match?('dog')).to be true
      end

      it 'does not match partial match' do
        expect(regex.match?('ca')).to be false
        expect(regex.match?('do')).to be false
      end
    end

    context 'with multiple choices' do
      let(:regex) { Hoozuki.new('red|green|blue') }

      it 'matches all choices' do
        expect(regex.match?('red')).to be true
        expect(regex.match?('green')).to be true
        expect(regex.match?('blue')).to be true
      end
    end
  end
end
