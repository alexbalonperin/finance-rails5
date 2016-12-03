require 'rails_helper'

RSpec.describe "watchlists/show", type: :view do
  before(:each) do
    @watchlist = assign(:watchlist, Watchlist.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
