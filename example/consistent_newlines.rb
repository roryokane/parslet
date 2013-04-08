# encoding: utf-8

# this parser matches newlines only if they’re the same as
#  the first newline in the text
# it accomplishes this by using a `dynamic` block containing `capture`

# make sure if you try this that any whitespace allowed inside
#  or at the ends of a line cannot contain "\r" or "\n",
#  or else text with inconsistent newlines may still parse

require 'parslet'
require 'rspec'
require 'parslet/rig/rspec'


class ConsistentNewlineTextParser < Parslet::Parser
  rule(:first_newline) do
    str("\r").maybe >> str("\n")
  end
  
  rule(:newline) do
    dynamic do |source, context|
      begin
        str(context.captures[:newline])
      rescue Parslet::Scope::NotFound
        first_newline.capture(:newline)
      end
    end
  end
  
  
  rule(:word) { match('\w').repeat }
  
  rule(:line_content) { word }
  
  rule(:lines) do
    (line_content.as(:line_content) >> newline).repeat >>
    line_content.as(:line_content)
  end
  
  root(:lines)
end


describe ConsistentNewlineTextParser do
  let(:parser) { described_class.new }
  
  let(:n1) { "\r\n" }
  let(:n2) { "\n" }
  
  it "allows text with the same newline throughout" do
    parser.should parse("")
    parser.should parse("one")
    
    # for each type of newline individually
    [n1, n2].each do |n|
      # the parser should parse these strings containing that newline
      parser.should parse("one#{n}")
      parser.should parse("one#{n}#{n}#{n}")
      parser.should parse("one#{n}two#{n}three")
      parser.should parse("one#{n}two#{n}three#{n}")
    end
  end
  
  it "rejects text with mixed newlines" do
    parser.should_not parse("one#{n1}two#{n2}")
    parser.should_not parse("one#{n2}two#{n1}")
    parser.should_not parse("one#{n1}two#{n2}three")
    parser.should_not parse("one#{n1}two#{n1}three#{n2}")
    parser.should_not parse("one#{n2}two#{n1}three#{n2}")
  end
end
