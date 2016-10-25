require 'spec_helper'
require 'financials/calculator'

RSpec.configure do |c|
  c.include Financials::Calculator::Growth
end

RSpec.describe Financials::Calculator do

  describe "Growth" do
    before do
      @years = {
          '2016' => {
              :debt_to_equity_ratio => 1
          },
          '2015' => {
              :debt_to_equity_ratio => 0.5
          },
          '2014' => {
              :debt_to_equity_ratio => 0.1
          }
      }
    end

    it "should calculate the growth between two values" do
      expect(growth(2, 1)).to eq(1)
    end

    it "should calculate average growth over a period of 2 years" do
      expect(avg(@years, 2, :debt_to_equity_ratio)).to eq 0.75
    end

    it "should calculate average growth over a period of 3 years" do
      expect(avg(@years, 3, :debt_to_equity_ratio)).to eq 1.6 / 3.0
    end

    it "should calculate the actual growth over a period of 2 years" do
      expect(period(@years, 2, :debt_to_equity_ratio)).to eq 1
    end

    it "should calculate the actual growth over a period of 3 years" do
      expect(period(@years, 3, :debt_to_equity_ratio)).to eq (0.9 / 0.1)
    end

    it "should calculate the yoy growth over a period of 2 years" do
      expect(yoy(@years, 2, :debt_to_equity_ratio)).to eq({'2016' => 1})
    end

    it "should calculate the yoy growth over a period of 3 years" do
      expect(yoy(@years, 3, :debt_to_equity_ratio)).to eq({'2016' => 1, '2015' => 4})
    end

    it "should calculate the avg yoy growth over a period of 2 years" do
      expect(avg_yoy(@years, 2, :debt_to_equity_ratio)).to eq(1)
    end

    it "should calculate the avg yoy growth over a period of 3 years" do
      expect(avg_yoy(@years, 3, :debt_to_equity_ratio)).to eq(2.5)
    end

  end
end