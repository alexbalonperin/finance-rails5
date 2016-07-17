require "rails_helper"

RSpec.describe IndustriesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/industries").to route_to("industries#index")
    end

    it "routes to #new" do
      expect(:get => "/industries/new").to route_to("industries#new")
    end

    it "routes to #show" do
      expect(:get => "/industries/1").to route_to("industries#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/industries/1/edit").to route_to("industries#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/industries").to route_to("industries#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/industries/1").to route_to("industries#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/industries/1").to route_to("industries#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/industries/1").to route_to("industries#destroy", :id => "1")
    end

  end
end
