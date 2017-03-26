document.addEventListener 'turbolinks:load', ->
  $table = $('#companies_table')
  utils = $.fn.bootstrapTable.utils

  industryLink = (value, row) ->
    '<a class="show" href="/industries/' + row.industry_id + '" title="Show industry: ' + row.industry + '">' + row.industry + '</a> '

  sectorLink = (value, row) ->
    '<a class="show" href="/sectors/' + row.sector_id + '" title="Show sector: ' + row.sector + '">' + row.sector + '</a> '

  operateFormatter = (value, row) ->
    [
      '<a class="show" href="/companies/' + row.id + '" title="Show company: ' + row.name + '">Show</a> '
    ].join('')

  columns = [ [
    {
      field: 'symbol'
      title: 'Symbol'
    }
    {
      field: 'name'
      title: 'Name'
      align: 'left'
    }
    {
      field: 'industry'
      title: 'Industry'
      align: 'left'
      formatter: industryLink
    }
    {
      field: 'sector'
      title: 'Sector'
      align: 'left'
      formatter: sectorLink
    }
    {
      field: 'details'
      title: 'Details'
      align: 'left'
      sortable: false
    }
    {
      title: ''
      align: 'center'
      sortable: false
      formatter: operateFormatter
    }
  ] ]

  sort_params = {
    industry: 'industries.name'
    sector: 'sectors.name'
  }

  options = {
    rowStyle : (row) ->
      if row.delisted
        return {
          classes: 'delisted'
        }
      if row.merged
        return {
          classes: 'merged'
        }
      if row.liquidated
        return {
          classes: 'liquidated'
        }
      if row.inactive
        return {
          classes: 'inactive'
        }
      if row.changed
        return {
          classes: 'changed'
        }
      return {}
  }
  utils.initTable($table, columns, sort_params, options)

  $chart_div = $('#company_chart')
  if $chart_div.length
    @stock_chart($chart_div)

  return


