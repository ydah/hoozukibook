# frozen_string_literal: true

class Hoozuki
  def initialize(pattern)
    @pattern = pattern
    @ast = Parser.new(pattern).parse
  end

  def match?(input)
    result = match_node(@ast, input, 0)
    result && result == input.length
  end

  private

  def match_node(node, input, pos)
    case node
    when Node::Literal
      match_literal(node, input, pos)
    when Node::Concatenation
      match_concatenation(node, input, pos)
    else
      false
    end
  end

  def match_literal(node, input, pos)
    return false if pos >= input.length
    return false if input[pos] != node.value

    pos + 1
  end

  def match_concatenation(node, input, pos)
    node.children.each do |child|
      result = match_node(child, input, pos)
      return false unless result
      pos = result
    end
    pos
  end
end
