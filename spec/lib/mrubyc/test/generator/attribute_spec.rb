# frozen_string_literal: true

RSpec.describe Mrubyc::Test::Generator::Attribute do

  after :each do
    SampleTest.send(:init_class_variables)
  end

  let :model_file do
    file_fixture('sample.rb')
  end
  let :test_file do
    file_fixture('sample_test.rb')
  end

  it "does not raise error" do
    expect{ Mrubyc::Test::Generator::Attribute.run(
      model_files: [model_file],
      test_files: [test_file]
    ) }.to_not raise_error
  end

  it "does not raise error without model_file" do
    expect{ Mrubyc::Test::Generator::Attribute.run(
      test_files: [test_file]
    ) }.to_not raise_error
  end

  it "raises error if test_file is not passed" do
    expect{ Mrubyc::Test::Generator::Attribute.run(
      model_files: [model_file]
    ) }.to raise_error(ArgumentError)
  end

end

