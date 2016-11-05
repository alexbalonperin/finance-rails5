require 'spec_helper'
require 'financials/basic_selector'

RSpec.configure do |c|
  c.include Financials::Calculator::Growth
  c.include Financials::Calculator::Compounding
end

RSpec.describe Financials::Calculator do

  ROE_MIN = 12
  EPS_MIN = 15
  FREE_CASH_FLOW_MIN = 0
  CURRENT_RATIO_MIN = 1
  POSITIVE_GROWTH_PERCENTAGE = 0.7
  STEADY_GROWTH_N_YEARS = 10
  before do
    good_ki = {
      '2015' => {

      },
      '2014' => {

      },
      '2013' => {

      },
      '2014' => {

      },
      '2014' => {

      },
      '2014' => {

      },
      '2014' => {

      },
      '2014' => {

      },
      '2014' => {

      },
      '2014' => {

      },
    }
  end

  it 'should select good companies' do
    ki = KeyIndicatorsBuilder::KeyIndicator.new(good_ki)

  end

end