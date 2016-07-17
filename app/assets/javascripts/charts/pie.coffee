buildPie = ->
  @pie = ($chart_div) ->
    options = ({
      chart: {
        backgroundColor: 'transparent'
        type: 'pie'
      }
      title: {
        text: null
      }
      colors: [@blue, @green, @yellow, @red, @blue_green]
      series: [{}]
    })
    url = $chart_div.data('url')
    $.getJSON url, (data) ->
      options.series[0].data = data
      $chart_div.highcharts(options)
      return

document.addEventListener 'turbolinks:load', buildPie
