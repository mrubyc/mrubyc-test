# frozen_string_literal: true


RSpec.describe MrubycTestCase do

  context "ext MrubycTestCase" do

    before :context do
      if Object.class_eval{ const_defined? :MrubycTestCase }
        Object.class_eval{ remove_const :MrubycTestCase }
      end
      load "mrubyc-ext/mrubyc_test_case.rb"
    end

    after :context do
      if Object.class_eval{ const_defined? :MrubycTestCase }
        Object.class_eval{ remove_const :MrubycTestCase }
      end
      # must be reloaded otherwise other specs will fail
      load "mrubyc_test_case/mrubyc_test_case.rb"
    end

    before :each do
      information = {
        test_class_name: "SampleTest",
        method_name: "sample_method",
        path: "/path/to/test",
        line: 100,
        description: "some description"
      }
      @case = MrubycTestCase.new(information)
    end

    it "should be success (:assert_equal)" do
      allow(@case).to receive(:success).and_return("hoge")
      @case.assert_equal true, true
    end

    it "should be failure (:assert_equal)" do
      allow(@case).to receive(:failure).and_return("hoge")
      @case.assert_equal true, false
    end

    it "should be success (:assert_not_equal)" do
      allow(@case).to receive(:success).and_return("hoge")
      @case.assert_not_equal nil, false
    end

    it "should be failure (:assert_not_equal)" do
      allow(@case).to receive(:failure).and_return("hoge")
      @case.assert_not_equal "a", "a"
    end

    it "should be success (:assert)" do
      allow(@case).to receive(:success).and_return("hoge")
      @case.assert 0
    end

    it "should be failure (:assert)" do
      allow(@case).to receive(:failure).and_return("hoge")
      @case.assert false
    end

    it "should be success (:assert_true)" do
      allow(@case).to receive(:success).once.and_return("hoge")
      @case.assert_true true
    end

    it "should be failure (:assert_true)" do
      allow(@case).to receive(:failure).and_return("hoge")
      @case.assert_true 0
    end

    it "should be success (:assert_false)" do
      allow(@case).to receive(:success).once.and_return("hoge")
      @case.assert_false false
    end

    it "should be failure (:assert_false)" do
      allow(@case).to receive(:failure).and_return("hoge")
      @case.assert_false nil
    end

    it "should be success (:assert_in_delta)" do
      allow(@case).to receive(:success).once.and_return("hoge")
      @case.assert_in_delta 1, 1.001
    end

    it "should be success (:assert_in_delta)" do
      allow(@case).to receive(:success).once.and_return("hoge")
      @case.assert_in_delta 0, -0.001
    end

    it "should be failure (:assert_in_delta)" do
      allow(@case).to receive(:failure).and_return("hoge")
      @case.assert_in_delta 1, 1.0011
    end

    it "should be failure (:assert_in_delta)" do
      allow(@case).to receive(:failure).and_return("hoge")
      @case.assert_in_delta -0.0011, 0
    end

  end

end
