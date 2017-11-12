#!/bin/bash

rake populate:sectors
rake populate:industries
rake populate:companies
rake populate:markets
rake update:symbol_changes
rake update:mergers
rake update:cik_to_company_name
rake update:latest_filings
rake populate:deactivate
rake populate:last_trade_date
rake populate:first_trade_date
rake populate:download_financials
rake populate:download_quarterly_financials
rake populate:import_financials
rake populate:import_quarterly_financials
rake update:historical_data

