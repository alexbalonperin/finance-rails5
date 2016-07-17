require 'rails_helper'

RSpec.describe "Markets", type: :request do
  describe "GET /markets" do
    it "works! (now write some real specs)" do
      get markets_path
      expect(response).to have_http_status(200)
    end
  end
end
