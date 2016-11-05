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
        'return_on_equity_5y_annual_compounding_' => 0.0
      },
      '2014' => {

      },
      '2013' => {

      },
      '2012' => {

      },
      '2011' => {

      },
      '2010' => {

      },
      '2009' => {

      },
      '2008' => {

      },
      '2007' => {

      },
      '2006' => {

      },
    }
  end

  it 'should select good companies' do
    ki = KeyIndicatorsBuilder::KeyIndicator.new(good_ki)

  end

end