require 'spec_helper'
require 'financials/calculator'

RSpec.configure do |c|
  c.include Financials::Calculator::Growth
end

RSpec.describe Financials::Calculator do

  describe "Growth" do
    before do
      @values = [1, 0.5, 0.1]
      @years = ['2016', '2015', '2014']
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
      expect(yoy(@values.take(2), @years.take(2))).to eq({'2016' => 1})
    end

    it "should calculate the yoy growth over a period of 3 years" do
      expect(yoy(@values, @years)).to eq({'2016' => 1, '2015' => 4})
    end

    it "should calculate the avg yoy growth over a period of 2 years" do
      expect(avg_yoy(@values.take(2), @years.take(2))).to eq(1)
    end

    it "should calculate the avg yoy growth over a period of 3 years" do
      expect(avg_yoy(@values, @years)).to eq(2.5)
    end

  end
end