# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

loadSectorPie = ->
  $chart_div = $('#sector_chart')
  if $chart_div.length
    @pie($chart_div)

document.addEventListener 'turbolinks:load', loadSectorPie

