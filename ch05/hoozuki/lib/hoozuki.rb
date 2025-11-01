# frozen_string_literal: true

require_relative 'hoozuki/node'
require_relative 'hoozuki/parser'
require_relative 'hoozuki/automaton'

class Hoozuki
  def initialize(pattern)
    @pattern = pattern

    ast = Parser.new(pattern).parse
    @nfa = Automaton::NFA.new_from_node(ast, Automaton::StateID.new(0))
  end

  def match?(input)
    @nfa.match?(input)
  end
end
