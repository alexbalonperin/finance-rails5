require 'rails_helper'

RSpec.describe "potential_investments/show", type: :view do
  before(:each) do
    @potential_investment = assign(:potential_investment, PotentialInvestment.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
