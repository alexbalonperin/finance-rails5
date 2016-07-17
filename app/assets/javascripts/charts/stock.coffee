seriesOptions = []
seriesCounter = 0

createChart = ($chart_div) ->
  $chart_div.highcharts 'StockChart',
    rangeSelector: selected: 4
    yAxis:
      labels: formatter: ->
        (if @value > 0 then ' + ' else '') + @value + '%'
      plotLines: [ {
        value: 0
        width: 2
        color: 'silver'
      } ]
    plotOptions: series: compare: 'percent'
    tooltip:
      pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b> ({point.change}%)<br/>'
      valueDecimals: 2
    series: seriesOptions
  return

loadStockChart = ->
  @stock_chart = ($chart_div) ->
    url = $chart_div.data('url')
    name = $chart_div.data('name')
    $.getJSON url, (data) ->
      seriesOptions[0] =
        name: name
        data: data
      createChart($chart_div)
      return
  return

document.addEventListener 'turbolinks:load', loadStockChart
