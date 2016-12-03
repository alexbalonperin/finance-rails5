require 'rails_helper'

RSpec.describe "watchlists/index", type: :view do
  before(:each) do
    assign(:watchlists, [
      Watchlist.create!(),
      Watchlist.create!()
    ])
  end

  it "renders a list of watchlists" do
    render
  end
end
