document.addEventListener 'turbolinks:load', ->
  $table = $('#historical_prices_table')
  utils = $.fn.bootstrapTable.utils

  columns =  [ [
    {
      field: 'trade_date'
      title: 'Trade Date'
    }
    {
      field: 'open'
      title: 'Open'
    }
    {
      field: 'high'
      title: 'High'
    }
    {
      field: 'low'
      title: 'Low'
    }
    {
      field: 'close'
      title: 'Close'
    }
    {
      field: 'volume'
      title: 'Volume',
      formatter: utils.commify
    }
    {
      field: 'adjusted_close'
      title: 'Adjusted close'
    }
  ] ]
  utils.initTable($table, columns, null, {sortOrder: 'desc'})
  return

