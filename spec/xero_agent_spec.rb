require 'rails_helper'
require 'huginn_agent/spec_helper'

describe Agents::XeroAgent do
  before(:each) do
    @valid_options = Agents::XeroAgent.new.default_options
    @checker = Agents::XeroAgent.new(:name => "XeroAgent", :options => @valid_options)
    @checker.user = users(:bob)
    @checker.save!
  end

  pending "add specs here"
end
