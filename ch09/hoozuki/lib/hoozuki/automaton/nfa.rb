# frozen_string_literal: true

require 'set'
require 'sorted_set'

class Hoozuki
  module Automaton
    class NFA
      attr_accessor :start, :accept, :transitions

      def initialize(start, accept)
        @start = start
        @accept = accept
        @transitions = Set.new
      end

      def add_transition(from, char, to)
        @transitions << [from, char, to]
      end

      def add_epsilon_transition(from, to)
        @transitions << [from, nil, to]
      end

      def epsilon_closure(start)
        visited = Set.new
        to_visit = []

        start.each do |state|
          to_visit << state unless visited.include?(state)
        end

        until to_visit.empty?
          state = to_visit.shift
          next if visited.include?(state)

          visited << state

          @transitions.each do |from, label, to|
            if from == state && label.nil? && !visited.include?(to)
              to_visit << to
            end
          end
        end

        ::SortedSet.new(visited)
      end

      def match?(input)
        current_states = epsilon_closure(Set[@start])
        input.each_char do |char|
          next_states = Set.new
          current_states.each do |state|
            @transitions.each do |from, label, to|
              next_states << to if from == state && label == char
            end
          end
          return false if next_states.empty?

          current_states = epsilon_closure(next_states)
        end
        current_states.any? { |state| @accept.include?(state) }
      end

      def self.new_from_node(node, state)
        raise ArgumentError, 'Node cannot be nil' if node.nil?

        case node
        when Node::Literal
          build_literal(node, state)
        when Node::Epsilon
          build_epsilon(state)
        when Node::Concatenation
          build_concatenation(node, state)
        when Node::Choice
          build_choice(node, state)
        when Node::Repetition
          if node.zero_or_more?
            build_zero_or_more(node.child, state)
          elsif node.one_or_more?
            build_one_or_more(node.child, state)
          elsif node.optional?
            build_optional(node.child, state)
          end
        else
          raise ArgumentError, "Unsupported node type: #{node.class}"
        end
      end

      private_class_method

      def self.build_literal(node, state)
        start_state = state.new_state
        accept_state = state.new_state

        nfa = new(start_state, [accept_state])
        nfa.add_transition(start_state, node.value, accept_state)
        nfa
      end

      def self.build_epsilon(state)
        start_state = state.new_state
        accept_state = state.new_state

        nfa = new(start_state, [accept_state])
        nfa.add_epsilon_transition(start_state, accept_state)
        nfa
      end

      def self.build_concatenation(node, state)
        nfas = node.children.map { |child| new_from_node(child, state) }
        nfa = nfas.first
        nfas.drop(1).each do |next_nfa|
          nfa.transitions.merge(next_nfa.transitions)
          nfa.accept.each do |accept_state|
            nfa.add_epsilon_transition(accept_state, next_nfa.start)
          end
          nfa.accept = next_nfa.accept
        end

        nfa
      end

      def self.build_choice(node, state)
        nfas = node.children.map { |child| new_from_node(child, state) }
        start_state = state.new_state
        accepts = nfas.flat_map(&:accept)
        nfa = new(start_state, accepts)

        nfas.each do |child_nfa|
          nfa.transitions.merge(child_nfa.transitions)
          nfa.add_epsilon_transition(start_state, child_nfa.start)
        end

        nfa
      end

      def self.build_zero_or_more(child_node, state)
        child_nfa = new_from_node(child_node, state)

        start_state = state.new_state
        accept_state = state.new_state

        nfa = new(start_state, [accept_state])
        nfa.transitions.merge(child_nfa.transitions)

        nfa.add_epsilon_transition(start_state, child_nfa.start)
        nfa.add_epsilon_transition(start_state, accept_state)

        child_nfa.accept.each do |child_accept|
          nfa.add_epsilon_transition(child_accept, accept_state)
          nfa.add_epsilon_transition(child_accept, child_nfa.start)
        end

        nfa
      end

      def self.build_one_or_more(child_node, state)
        child_nfa = new_from_node(child_node, state)

        start_state = state.new_state
        accept_state = state.new_state

        nfa = new(start_state, [accept_state])
        nfa.transitions.merge(child_nfa.transitions)
        nfa.add_epsilon_transition(start_state, child_nfa.start)

        child_nfa.accept.each do |child_accept|
          nfa.add_epsilon_transition(child_accept, accept_state)
          nfa.add_epsilon_transition(child_accept, child_nfa.start)
        end

        nfa
      end

      def self.build_optional(child_node, state)
        child_nfa = new_from_node(child_node, state)
        start_state = state.new_state

        accepts = child_nfa.accept.dup
        accepts << start_state

        nfa = new(start_state, accepts)
        nfa.transitions.merge(child_nfa.transitions)

        nfa.add_epsilon_transition(start_state, child_nfa.start)

        nfa
      end

    end
  end
end
