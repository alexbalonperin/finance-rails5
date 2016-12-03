require 'rails_helper'

RSpec.describe "watchlists/new", type: :view do
  before(:each) do
    assign(:watchlist, Watchlist.new())
  end

  it "renders new watchlist form" do
    render

    assert_select "form[action=?][method=?]", watchlists_path, "post" do
    end
  end
end
