document.addEventListener 'turbolinks:load', ->
  $('.add-to-watchlist').on 'click', (event) ->
    event.preventDefault()
    $.ajax
      url: "/watchlists/"
      type: 'POST'
      contentType: "application/json"
      dataType: 'json'
      data: JSON.stringify({'watchlist': {'company_id' : $(this).data('id') } })
      error: (jqXHR, textStatus, errorThrown) ->
        $('.potential-investments .content').prepend """
            <div class="alert alert-warning">
              <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
              <strong>Error!</strong> #{jqXHR.responseText}
            </div>
          """
      success: (data, textStatus, jqXHR) ->
        $('.potential-investments .content').prepend """
            <div class="alert alert-success">
              <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
              <strong>Success!</strong> #{data.notice}
            </div>
          """
