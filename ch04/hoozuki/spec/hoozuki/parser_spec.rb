# frozen_string_literal: true

require_relative '../../lib/hoozuki/parser'
require_relative '../../lib/hoozuki/node'

RSpec.describe Hoozuki::Parser do
  describe '#parse' do
    it 'parses single character' do
      ast = Hoozuki::Parser.new('a').parse

      expect(ast).to be_a(Hoozuki::Node::Literal)
      expect(ast.value).to eq('a')
    end

    it 'parses multiple characters as concatenation' do
      ast = Hoozuki::Parser.new('abc').parse

      expect(ast).to be_a(Hoozuki::Node::Concatenation)
      expect(ast.children.length).to eq(3)
      expect(ast.children[0].value).to eq('a')
      expect(ast.children[1].value).to eq('b')
      expect(ast.children[2].value).to eq('c')
    end

    it 'handles multibyte characters' do
      ast = Hoozuki::Parser.new('こんにちは').parse

      expect(ast).to be_a(Hoozuki::Node::Concatenation)
      expect(ast.children.length).to eq(5)
      expect(ast.children[0].value).to eq('こ')
      expect(ast.children[1].value).to eq('ん')
    end
  end
end
