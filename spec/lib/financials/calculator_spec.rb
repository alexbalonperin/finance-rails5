require 'spec_helper'
require 'financials/calculator'

RSpec.configure do |c|
  c.include Financials::Calculator::Growth
  c.include Financials::Calculator::Compounding
end

RSpec.describe Financials::Calculator do

  describe "Growth" do
    before do
      @values = [1, 0.5, 0.1]
      @years = ['2016', '2015', '2014']
      @data = @years.zip(@values).to_h
    end

    it "should calculate the growth between two values" do
      expect(growth(2, 1)).to eq(1)
    end

    it "should calculate average growth over a period of 2 years" do
      expect(avg(@values.take(2))).to eq 0.75
    end

    it "should calculate average growth over a period of 3 years" do
      expect(avg(@values)).to eq 1.6 / 3.0
    end

    it "should calculate the actual growth over a period of 2 years" do
      expect(period(@values.take(2))).to eq 1
    end

    it "should calculate the actual growth over a period of 3 years" do
      expect(period(@values)).to eq (0.9 / 0.1)
    end

    it "should calculate the yoy growth over a period of 2 years" do
      expect(yoy(@data.take(2))).to eq({'2016' => 1})
    end

    it "should calculate the yoy growth over a period of 3 years" do
      expect(yoy(@data)).to eq({'2016' => 1, '2015' => 4})
    end

    it "should calculate the avg yoy growth over a period of 2 years" do
      expect(avg_yoy(@data.take(2))).to eq(1)
    end

    it "should calculate the avg yoy growth over a period of 3 years" do
      expect(avg_yoy(@data)).to eq(2.5)
    end

  end

  describe "Compounding" do
    before do
      @years = {'2015' => 1.33, '2014' => 1.23, '2013' => 0.23}
    end

    it 'should return an array with yoy annual rate of return' do
      expected = {
          '2015' => annual_rate_of_return(0.23, 1.33, 2),
          '2014' => annual_rate_of_return(0.23, 1.23, 1)
      }

      expect(yoy_annual_rate_of_return(@years)).to eq(expected)
    end

  end
end
