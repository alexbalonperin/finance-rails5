require 'rails_helper'

RSpec.describe "potential_investments/index", type: :view do
  before(:each) do
    assign(:potential_investments, [
      PotentialInvestment.create!(),
      PotentialInvestment.create!()
    ])
  end

  it "renders a list of potential_investments" do
    render
  end
end
