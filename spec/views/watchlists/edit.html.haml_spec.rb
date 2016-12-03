require 'rails_helper'

RSpec.describe "watchlists/edit", type: :view do
  before(:each) do
    @watchlist = assign(:watchlist, Watchlist.create!())
  end

  it "renders the edit watchlist form" do
    render

    assert_select "form[action=?][method=?]", watchlist_path(@watchlist), "post" do
    end
  end
end
