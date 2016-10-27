require 'rails_helper'

RSpec.describe "potential_investments/edit", type: :view do
  before(:each) do
    @potential_investment = assign(:potential_investment, PotentialInvestment.create!())
  end

  it "renders the edit potential_investment form" do
    render

    assert_select "form[action=?][method=?]", potential_investment_path(@potential_investment), "post" do
    end
  end
end
