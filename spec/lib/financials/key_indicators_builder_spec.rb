require 'rails_helper'
require 'spec_helper'
require 'financials/key_indicators_builder'

RSpec.describe Financials::KeyIndicatorsBuilder do

  describe 'one year' do
    before do
      @company = FactoryGirl.create(:company_with_statements)
    end

    it 'should not throw an exception' do
      kib = Financials::KeyIndicatorsBuilder.new(@company)
      expect { kib.build }.not_to raise_error
    end

    it 'should calculate key indicators' do
      kib = Financials::KeyIndicatorsBuilder.new(@company)
      ki = kib.build
      expect(ki.per_year['2015']['debt_to_equity'].to_f.round(5)).to eq((45387000.0 / 108201000.0).round(5))
      expect(ki.per_year['2015']['eps_basic'].to_f).to eq(1.19)
      expect(ki.per_year['2015']['free_cash_flow'].to_f.round(5)).to eq((12200000.0 - 2719000.0).round(5))
      expect(ki.per_year['2015']['current_ratio'].to_f.round(5)).to eq((57002000.0 / 23637000.0).round(5))
      expect(ki.per_year['2015']['net_margin'].to_f.round(5)).to eq((34766000.0 / 558524000.0).round(5))

    end
  end

  describe 'growth over 2 years' do

  end
end
