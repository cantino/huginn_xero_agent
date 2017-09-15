require 'rails_helper'
require 'huginn_agent/spec_helper'

describe Agents::XeroAgent do
  before(:each) do
    @valid_options = Agents::XeroAgent.new.default_options
    @checker = Agents::XeroAgent.new(:name => "XeroAgent", :options => @valid_options)
    @checker.user = users(:bob)
    @checker.save!
  end

  describe "validation" do
    before do
      expect(@checker).to be_valid
    end

    it "should validate integer nature of due_in_days" do
      @checker.options[:due_in_days] = "a"
      expect(@checker).not_to be_valid

      @checker.options[:due_in_days] = "1.1"
      expect(@checker).not_to be_valid

      @checker.options[:due_in_days] = "1"
      expect(@checker).to be_valid

      @checker.options[:due_in_days] = 1
      expect(@checker).to be_valid
    end

    it "should validate presence of expected_receive_period_in_days" do
      @checker.options[:expected_receive_period_in_days] = nil
      expect(@checker).not_to be_valid
    end

    it "should validate presence of item_description" do
      @checker.options[:item_description] = nil
      expect(@checker).not_to be_valid
    end

    it "should validate presence of item_amount" do
      @checker.options[:item_amount] = nil
      expect(@checker).not_to be_valid
    end
  end
end
