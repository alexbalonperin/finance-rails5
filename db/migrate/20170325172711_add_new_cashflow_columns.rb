class AddNewCashflowColumns < ActiveRecord::Migration[5.0]
  def change
      add_column :cash_flow_statements, :share_based_compensation, :decimal
      add_column :cash_flow_statements, :net_cash_flow_business_acquisitions_and_disposals, :decimal
      add_column :cash_flow_statements, :net_cash_flow_investment_acquisitions_and_disposals, :decimal
      add_column :cash_flow_statements, :free_cash_flow, :decimal
  end
end
