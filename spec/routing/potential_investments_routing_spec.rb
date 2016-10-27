require "rails_helper"

RSpec.describe PotentialInvestmentsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/potential_investments").to route_to("potential_investments#index")
    end

    it "routes to #new" do
      expect(:get => "/potential_investments/new").to route_to("potential_investments#new")
    end

    it "routes to #show" do
      expect(:get => "/potential_investments/1").to route_to("potential_investments#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/potential_investments/1/edit").to route_to("potential_investments#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/potential_investments").to route_to("potential_investments#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/potential_investments/1").to route_to("potential_investments#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/potential_investments/1").to route_to("potential_investments#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/potential_investments/1").to route_to("potential_investments#destroy", :id => "1")
    end

  end
end
