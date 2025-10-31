# frozen_string_literal: true

class Hoozuki
  class Parser
    def initialize(pattern)
      @pattern = pattern
      @offset = 0
    end

    def parse
      children = []
      until eol?
        char = current
        children << Node::Literal.new(char)
        next_char
      end
      return children.first if children.length == 1
      Node::Concatenation.new(children)
    end

    private

    def current
      @pattern[@offset]
    end

    def eol?
      @offset >= @pattern.length
    end

    def next_char
      @offset += 1
    end
  end
end
