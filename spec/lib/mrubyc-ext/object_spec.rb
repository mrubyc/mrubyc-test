# frozen_string_literal: true

require "mrubyc-ext/object"

RSpec.describe Object do

  it "should be nil [NilClass]" do
    expect( nil.to_ss ).to eq "nil [NilClass]"
  end

  it "should be NULL String" do
    expect( "".to_ss ).to eq "[NULL String]"
  end

  it "should be TrueClass" do
    expect( true.class_name ).to eq "TrueClass"
  end

end
