# frozen_string_literal: true

class Hoozuki
  module Automaton
    class DFA
      attr_reader :start, :accept, :transitions

      def initialize(start, accept)
        @start = start
        @accept = accept
        @transitions = Set.new
        @cache = {}
      end

      def self.from_nfa(nfa, use_cache = false)
        dfa_states = {}
        queue = []
        nfa_accept_set = nfa.accept.to_set
        start_set = Set.new([nfa.start])
        start_states = nfa.epsilon_closure(start_set)
        dfa_states[start_states] = 0
        queue << start_states
        dfa = new(0, Set.new)

        while (current_nfa_states = queue.shift)
          current_dfa_id = dfa_states[current_nfa_states]
          if current_nfa_states.any? { |state| nfa_accept_set.include?(state) }
            dfa.accept << current_dfa_id
          end

          transitions_map = Hash.new { |h, k| h[k] = Set.new }
          current_nfa_states.each do |state|
            nfa.transitions.each do |from, label, to|
              next if from != state || label.nil?

              transitions_map[label].merge(nfa.epsilon_closure(Set[to]))
            end
          end

          transitions_map.each do |char, next_nfa_states|
            unless dfa_states.key?(next_nfa_states)
              next_dfa_id = dfa_states.length
              dfa_states[next_nfa_states] = next_dfa_id
              queue << next_nfa_states
            end

            next_dfa_id = dfa_states[next_nfa_states]
            dfa.add_transition(current_dfa_id, char, next_dfa_id)
            dfa.cache[[current_dfa_id, char]] = next_dfa_id if use_cache
          end
        end

        dfa
      end

      def add_transition(from, char, to)
        @transitions << [from, char, to]
      end

      def match?(input, use_cache = false)
        state = @start

        input.each_char do |char|
          if use_cache && (cached = @cache[[state, char]])
            state = cached
          else
            state = next_transition(state, char, use_cache)
          end

          return false unless state
        end

        @accept.include?(state)
      end

      def next_transition(current, input, use_cache)
        next_state = @transitions.find { |from, label, _| 
          from == current && label == input 
        }&.last

        @cache[[current, input]] = next_state if use_cache && next_state

        next_state
      end

      private

      attr_accessor :cache
    end
  end
end
