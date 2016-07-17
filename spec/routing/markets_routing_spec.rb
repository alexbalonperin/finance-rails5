require "rails_helper"

RSpec.describe MarketsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/markets").to route_to("markets#index")
    end

    it "routes to #new" do
      expect(:get => "/markets/new").to route_to("markets#new")
    end

    it "routes to #show" do
      expect(:get => "/markets/1").to route_to("markets#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/markets/1/edit").to route_to("markets#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/markets").to route_to("markets#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/markets/1").to route_to("markets#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/markets/1").to route_to("markets#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/markets/1").to route_to("markets#destroy", :id => "1")
    end

  end
end
