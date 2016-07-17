require "rails_helper"

RSpec.describe HistoricalDataController, type: :routing do
  describe "routing" do

    context 'routes for historical data' do

      it 'routes to #list' do
        expect(:get => '/companies/1/historical_data/list').to route_to('historical_data#list', :company_id => '1')
      end

      it 'routes to #prices' do
        expect(:get => '/companies/1/historical_data/prices').to route_to('historical_data#prices', :company_id => '1')
      end


    end

  end
end
