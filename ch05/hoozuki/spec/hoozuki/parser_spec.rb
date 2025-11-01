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

    it 'parses choice pattern' do
      ast = Hoozuki::Parser.new('a|b').parse

      expect(ast).to be_a(Hoozuki::Node::Choice)
      expect(ast.children.length).to eq(2)
      expect(ast.children[0]).to be_a(Hoozuki::Node::Literal)
      expect(ast.children[0].value).to eq('a')
      expect(ast.children[1]).to be_a(Hoozuki::Node::Literal)
      expect(ast.children[1].value).to eq('b')
    end

    it 'parses choice with concatenation' do
      ast = Hoozuki::Parser.new('cat|dog').parse

      expect(ast).to be_a(Hoozuki::Node::Choice)
      expect(ast.children.length).to eq(2)

      cat = ast.children[0]

      expect(cat).to be_a(Hoozuki::Node::Concatenation)
      expect(cat.children.length).to eq(3)
      expect(cat.children[0].value).to eq('c')
      expect(cat.children[1].value).to eq('a')
      expect(cat.children[2].value).to eq('t')

      dog = ast.children[1]

      expect(dog).to be_a(Hoozuki::Node::Concatenation)
      expect(dog.children.length).to eq(3)
      expect(dog.children[0].value).to eq('d')
      expect(dog.children[1].value).to eq('o')
      expect(dog.children[2].value).to eq('g')
    end

    it 'parses multiple choices' do
      ast = Hoozuki::Parser.new('a|b|c').parse

      expect(ast).to be_a(Hoozuki::Node::Choice)
      expect(ast.children.length).to eq(3)
    end
  end
end
