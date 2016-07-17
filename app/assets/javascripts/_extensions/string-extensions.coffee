String::toUnderscore = ->
  value = @charAt(0).toLowerCase() + @slice(1)
  value.replace /([A-Z])/g, ($1) ->
    '_' + $1.toLowerCase()

String::commify = ->
  @replace(/\B(?=(\d{3})+(?!\d))/g, ",")
