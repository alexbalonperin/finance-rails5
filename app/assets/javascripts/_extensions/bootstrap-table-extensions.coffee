document.addEventListener 'turbolinks:load', ->
  'use strict'
  $.extend $.fn.bootstrapTable.columnDefaults,
    align: 'center'
    class: 'nowrap'
    sortable: true
  $.extend $.fn.bootstrapTable.utils,
    toPercent: (value) ->
      value  + '%'
    toCurrency: (value) ->
      value.toString().commify() + '円'
    commify: (value) ->
      value.toString().commify()
    initTable: (table, col, sortParams, options = {}) ->
      pageSize = options.pageSize ? 100
      stickyHeader = options.stickyHeader ? true
      paginationVAlign = options.paginationVAlign ? 'both'
      sortOrder = options.sortOrder ? 'asc'
      searchOnEnterKey = options.searchOnEnterKey ? true
      sortParams = sortParams ? {}
      rowStyle = options.rowStyle ? {}
      fixedColumns = options.fixedColumns ? false
      fixedNumber = options.fixedNumber ? 0

      table.bootstrapTable
        pageSize: pageSize
        stickyHeader: stickyHeader
        paginationVAlign: paginationVAlign
        columns: col
        sortOrder: sortOrder
        searchOnEnterKey: searchOnEnterKey
        rowStyle: rowStyle
        fixedColumns: fixedColumns
        fixedNumber: fixedNumber
        queryParams: (params) ->
          if sortParams[params['sort']] != undefined
            params['sort'] = sortParams[params['sort']]
          params
      # sometimes footer render error.
      setTimeout (->
        table.bootstrapTable 'resetView'
        return
      ), 200
      $(window).resize ->
        table.bootstrapTable 'resetView'
        return
      return
  return

