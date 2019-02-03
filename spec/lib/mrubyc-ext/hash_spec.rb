# frozen_string_literal: true

require "mrubyc-ext/hash.rb"

RSpec.describe Hash do

  before :each do
    @hash = Hash.new
  end

  it "does respond to :add_by_key" do
    expect( @hash.respond_to?(:add_by_key) ).to eq true
  end

  it "should count up after add_by_key" do
    @hash[:some_count] = 0
    @hash.add_by_key(:some_count)
    expect( @hash[:some_count] ).to eq 1
  end

  it "should init a key that has value as 1" do
    @hash.add_by_key(:new_key)
    expect( @hash[:new_key] ).to eq 1
  end

end
