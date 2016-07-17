now = ->
  n = new Date
  formatDate n

formatDate = (date) ->
  hours = date.getHours()
  minutes = date.getMinutes()
  minutes = if minutes < 10 then '0' + minutes else minutes
  strTime = hours + '' + minutes
  month = date.getMonth() + 1
  month = if month < 10 then '0' + month else month
  date.getFullYear() + '' + month + '' + date.getDate() + '' + strTime

