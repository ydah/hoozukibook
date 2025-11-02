# frozen_string_literal: true

require_relative 'hoozuki/node'
require_relative 'hoozuki/parser'
require_relative 'hoozuki/automaton'

class Hoozuki
  def initialize(pattern)
    @pattern = pattern

    ast = Parser.new(pattern).parse
    nfa = Automaton::NFA.new_from_node(ast, Automaton::StateID.new(0))
    @dfa = Automaton::DFA.from_nfa(nfa, use_cache?(pattern))
  end

  def match?(input)
    @dfa.match?(input, use_cache?(input))
  end

  private

  def use_cache?(input)
    input.length > 1000
  end
end
