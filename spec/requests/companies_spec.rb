require 'rails_helper'

RSpec.describe 'Companies', type: :request do
  describe 'GET /companies' do
    it 'works!' do
      get companies_path
      expect(response).to have_http_status(200)
    end
  end
end
