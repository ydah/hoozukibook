# frozen_string_literal: true

class Hoozuki
  class Parser
    def initialize(pattern)
      @pattern = pattern
      @offset = 0
    end

    def parse
      ast = parse_choice

      raise "Unexpected character '#{current}' at position #{@offset}" unless eol?

      ast
    end

    private

    def parse_choice
      children = []
      children << parse_concatenation

      while current == '|'
        next_char
        children << parse_concatenation
      end

      return children.first if children.length == 1
      return Node::Epsilon.new if children.empty?
      Node::Choice.new(children)
    end

    def parse_concatenation
      children = []

      until stop_parsing_concatenation?
        children << parse_repetition
      end

      return children.first if children.length == 1
      return Node::Epsilon.new if children.empty?
      Node::Concatenation.new(children)
    end

    def parse_repetition
      child = parse_group

      quantifier = nil
      case current
      when '*'
        quantifier = :zero_or_more
      when '+'
        quantifier = :one_or_more
      when '?'
        quantifier = :optional
      end

      return child if quantifier.nil?

      next_char
      Node::Repetition.new(child, quantifier)
    end

    def parse_group
      return parse_literal if current != '('

      paren_pos = @offset
      next_char

      child = parse_choice

      if current != ')'
        raise "Expected closing parenthesis for '(' at position " \
              "#{paren_pos}. Got: #{current || 'end of pattern'}"
      end

      next_char
      child
    end

    def parse_literal
      raise 'Unexpected end of pattern' if eol?

      char = current
      if char == '\\'
        return parse_escape
      end

      case char
      when '(', ')', '|', '*', '+', '?'
        raise "Unexpected character '#{char}' at position #{@offset}"
      else
        next_char
        Node::Literal.new(char)
      end
    end

    def parse_escape
      escape_pos = @offset
      next_char

      if eol?
        raise "Incomplete escape sequence at position #{escape_pos}"
      end

      escaped_char = current
      next_char
      Node::Literal.new(escaped_char)
    end

    def stop_parsing_concatenation?
      eol? || current == '|' || current == ')'
    end

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
