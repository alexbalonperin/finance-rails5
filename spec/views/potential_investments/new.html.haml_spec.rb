require 'rails_helper'

RSpec.describe "potential_investments/new", type: :view do
  before(:each) do
    assign(:potential_investment, PotentialInvestment.new())
  end

  it "renders new potential_investment form" do
    render

    assert_select "form[action=?][method=?]", potential_investments_path, "post" do
    end
  end
end
