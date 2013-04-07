# encoding: utf-8

# example grammar matching “n ‘a’s followed by n ‘b’s”,
#  with the help of `dynamic`
# the language that this matches is a popular example of
#  a language that no formal regular expression can match

require 'parslet'
require 'rspec'
require 'parslet/rig/rspec'


class NAThenNBParser < Parslet::Parser
	root(:a_s_then_b_s)
	rule(:a_s_then_b_s) do
		str('a').repeat(0).capture(:a_s).as(:a_s) >>
		dynamic do |source, context|
			num_a_s = context.captures[:a_s].size
			# FIXME Parslet bug: something.repeat(0,0) can match one something
			#puts num_a_s
			str('b').repeat(num_a_s, num_a_s).as(:b_s)
		end
	end
end


describe NAThenNBParser do
	let(:parser) { described_class.new }
	
	it "parses ‘a’s and ‘b’s of the same number" do
		parser.should parse("")
		parser.should parse("ab")
		parser.should parse("aabb")
		parser.should parse("aaabbb")
	end
	
	it "rejects uneven ‘a’s and ‘b’s" do
		parser.should_not parse("a")
		parser.should_not parse("b")
		parser.should_not parse("aab")
		parser.should_not parse("abb")
		parser.should_not parse("aaab")
		parser.should_not parse("abbb")
	end
	
	it "rejects other invalid input" do
		parser.should_not parse("baa")
		parser.should_not parse("bbaa")
	end
end
