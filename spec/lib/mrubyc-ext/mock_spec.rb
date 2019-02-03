# frozen_string_literal: true

require "mrubyc-ext/mock"

RSpec.describe Mock do

  before :each do
    @mock = Mock.new
  end

  it "should have @actual" do
    expect( @mock.actual.class ).to eq Hash
    expect( @mock.respond_to?(:actual=) ).to eq true
  end

  it "should have @expected" do
    expect( @mock.expected.class ).to eq Hash
    expect( @mock.respond_to?(:expected=) ).to eq true
  end

end
