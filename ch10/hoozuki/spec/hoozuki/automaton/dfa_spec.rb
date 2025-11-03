# frozen_string_literal: true

require_relative '../../../lib/hoozuki'
require_relative '../../../lib/hoozuki/automaton'

RSpec.describe Hoozuki::Automaton::DFA do
  describe '.from_nfa' do
    it 'converts simple NFA to DFA' do
      node = Hoozuki::Node::Literal.new('a')
      state = Hoozuki::Automaton::StateID.new(0)
      nfa = Hoozuki::Automaton::NFA.new_from_node(node, state)
      dfa = described_class.from_nfa(nfa)

      expect(dfa.start).to be_an(Integer)
      expect(dfa.accept).to be_a(Set)
      expect(dfa.accept).not_to be_empty
      expect(dfa.transitions).not_to be_empty
    end

    it 'converts choice NFA to DFA' do
      node = Hoozuki::Node::Choice.new([
        Hoozuki::Node::Literal.new('a'),
        Hoozuki::Node::Literal.new('b')
      ])
      state = Hoozuki::Automaton::StateID.new(0)
      nfa = Hoozuki::Automaton::NFA.new_from_node(node, state)
      dfa = described_class.from_nfa(nfa)

      expect(dfa.start).to be_an(Integer)
      expect(dfa.accept.size).to be >= 1
      transitions_chars = dfa.transitions.map { |_, char, _| char }
      expect(transitions_chars).to include('a', 'b')
    end

    it 'converts concatenation NFA to DFA' do
      node = Hoozuki::Node::Concatenation.new([
        Hoozuki::Node::Literal.new('a'),
        Hoozuki::Node::Literal.new('b')
      ])
      state = Hoozuki::Automaton::StateID.new(0)
      nfa = Hoozuki::Automaton::NFA.new_from_node(node, state)
      dfa = described_class.from_nfa(nfa)

      expect(dfa.start).to be_an(Integer)
      expect(dfa.accept).not_to be_empty
    end
  end

  describe '#match?' do
    it 'matches using DFA' do
      node = Hoozuki::Node::Literal.new('a')
      state = Hoozuki::Automaton::StateID.new(0)
      nfa = Hoozuki::Automaton::NFA.new_from_node(node, state)
      dfa = described_class.from_nfa(nfa)

      expect(dfa.match?('a')).to be true
      expect(dfa.match?('b')).to be false
    end

    it 'matches choice pattern using DFA' do
      node = Hoozuki::Node::Choice.new([
        Hoozuki::Node::Literal.new('a'),
        Hoozuki::Node::Literal.new('b')
      ])
      state = Hoozuki::Automaton::StateID.new(0)
      nfa = Hoozuki::Automaton::NFA.new_from_node(node, state)
      dfa = described_class.from_nfa(nfa)

      expect(dfa.match?('a')).to be true
      expect(dfa.match?('b')).to be true
      expect(dfa.match?('c')).to be false
    end

    it 'matches concatenation pattern using DFA' do
      node = Hoozuki::Node::Concatenation.new([
        Hoozuki::Node::Literal.new('a'),
        Hoozuki::Node::Literal.new('b')
      ])
      state = Hoozuki::Automaton::StateID.new(0)
      nfa = Hoozuki::Automaton::NFA.new_from_node(node, state)
      dfa = described_class.from_nfa(nfa)

      expect(dfa.match?('ab')).to be true
      expect(dfa.match?('a')).to be false
      expect(dfa.match?('b')).to be false
    end
  end
end
