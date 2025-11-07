# frozen_string_literal: true

require_relative '../../../lib/hoozuki'
require_relative '../../../lib/hoozuki/automaton'

RSpec.describe Hoozuki::Automaton::NFA do
  describe '.new_from_node' do
    it 'builds NFA from Literal node' do
      node = Hoozuki::Node::Literal.new('a')
      state = Hoozuki::Automaton::StateID.new(0)

      nfa = described_class.new_from_node(node, state)

      expect(nfa.start).to be_a(Hoozuki::Automaton::StateID)
      expect(nfa.accept).to be_an(Array)
      expect(nfa.accept.length).to eq(1)
      expect(nfa.transitions.size).to eq(1)
    end

    it 'builds NFA from Epsilon node' do
      node = Hoozuki::Node::Epsilon.new
      state = Hoozuki::Automaton::StateID.new(0)

      nfa = described_class.new_from_node(node, state)

      expect(nfa.start).to be_a(Hoozuki::Automaton::StateID)
      expect(nfa.accept.length).to eq(1)
      epsilon_transitions = nfa.transitions.select { |_, label, _| label.nil? }
      expect(epsilon_transitions.size).to eq(1)
    end

    it 'builds NFA from Concatenation node' do
      node = Hoozuki::Node::Concatenation.new([
        Hoozuki::Node::Literal.new('a'),
        Hoozuki::Node::Literal.new('b')
      ])
      state = Hoozuki::Automaton::StateID.new(0)

      nfa = described_class.new_from_node(node, state)

      expect(nfa.start).to be_a(Hoozuki::Automaton::StateID)
      expect(nfa.accept.length).to eq(1)
      expect(nfa.transitions.size).to be >= 3
    end

    it 'builds NFA from Choice node' do
      node = Hoozuki::Node::Choice.new([
        Hoozuki::Node::Literal.new('a'),
        Hoozuki::Node::Literal.new('b')
      ])
      state = Hoozuki::Automaton::StateID.new(0)

      nfa = described_class.new_from_node(node, state)

      expect(nfa.start).to be_a(Hoozuki::Automaton::StateID)
      expect(nfa.accept.length).to eq(2)

      epsilon_transitions = nfa.transitions.select { |_, label, _| label.nil? }
      expect(epsilon_transitions.size).to eq(2)
    end

    it 'builds NFA from Repetition node' do
      node = Hoozuki::Node::Repetition.new(
        Hoozuki::Node::Literal.new('a'),
        :zero_or_more
      )
      state = Hoozuki::Automaton::StateID.new(0)
      nfa = described_class.new_from_node(node, state)

      expect(nfa.start).to be_a(Hoozuki::Automaton::StateID)
      expect(nfa.accept.length).to eq(1)

      epsilon_transitions = nfa.transitions.select { |_, label, _| label.nil? }
      expect(epsilon_transitions.size).to be >= 4
    end
  end

  describe '#epsilon_closure' do
    it 'computes epsilon closure of a single state' do
      state = Hoozuki::Automaton::StateID.new(0)
      s0 = state.new_state
      s1 = state.new_state
      s2 = state.new_state

      nfa = described_class.new(s0, [s2])
      nfa.add_epsilon_transition(s0, s1)
      nfa.add_epsilon_transition(s1, s2)

      closure = nfa.epsilon_closure(Set[s0])
      expect(closure).to include(s0, s1, s2)
    end
  end

  describe '#match?' do
    it 'matches single character' do
      node = Hoozuki::Node::Literal.new('a')
      state = Hoozuki::Automaton::StateID.new(0)
      nfa = described_class.new_from_node(node, state)

      expect(nfa.match?('a')).to be true
      expect(nfa.match?('b')).to be false
      expect(nfa.match?('')).to be false
    end

    it 'matches concatenation' do
      node = Hoozuki::Node::Concatenation.new([
        Hoozuki::Node::Literal.new('a'),
        Hoozuki::Node::Literal.new('b')
      ])
      state = Hoozuki::Automaton::StateID.new(0)
      nfa = described_class.new_from_node(node, state)

      expect(nfa.match?('ab')).to be true
      expect(nfa.match?('a')).to be false
      expect(nfa.match?('b')).to be false
      expect(nfa.match?('abc')).to be false
    end

    it 'matches choice' do
      node = Hoozuki::Node::Choice.new([
        Hoozuki::Node::Literal.new('a'),
        Hoozuki::Node::Literal.new('b')
      ])
      state = Hoozuki::Automaton::StateID.new(0)
      nfa = described_class.new_from_node(node, state)

      expect(nfa.match?('a')).to be true
      expect(nfa.match?('b')).to be true
      expect(nfa.match?('c')).to be false
      expect(nfa.match?('ab')).to be false
    end

    it 'matches repetition pattern' do
      node = Hoozuki::Node::Repetition.new(
        Hoozuki::Node::Literal.new('a'),
        :zero_or_more
      )
      state = Hoozuki::Automaton::StateID.new(0)
      nfa = described_class.new_from_node(node, state)

      expect(nfa.match?('')).to be true
      expect(nfa.match?('a')).to be true
      expect(nfa.match?('aaa')).to be true
      expect(nfa.match?('b')).to be false
    end
  end
end
