$(document).ready ->
  $('textarea').each ->
    t = $(this).text()
    $(this).text($.trim(t))

  $('.dropdown-toggle').dropdown()
  
  $('.nav-tabs a').click (ev) ->
    e.preventDefault()
    $(this).tab('show')
  
  $('.nav-tabs a:first').tab('show')

  $("[data-href]").click (ev) ->
    return if ev.metaKey || ev.ctrlKey || ev.button == 1
    url = $(this).data("href")
    if(url.length > 0)
      location.href = url

  $(".suppress_click").click (ev) ->
    ev.stopPropagation()

  $('.rating').raty(
    readOnly : true,
    path: '/assets/',
    score: ->
      return $(this).attr('data-rating')
  )

  $(".new_topic textarea, .edit_topic textarea, .new_post textarea, .edit_post textarea, #user_signature").each ->
    new nicEditor(
      iconsPath : '/assets/nicEditorIcons.gif',
      buttonList : ['fontSize', 'bold', 'italic', 'underline', 'left', 'center', 'right', 'ul', 'strikethrough', 'indent', 'outdent', 'hr', 'image', 'forecolor', 'bgcolor', 'link', 'unlink']
    ).panelInstance(this.id)

  $(".more").live 'click', ->
    more_link = $(this)
    url = more_link.attr("href")
    $.get url, (html) ->
      more_link.parent().append(html)
      more_link.remove()
      
      $('.rating').raty(
        readOnly : true,
        path: '/assets/',
        score: ->
          return $(this).attr('data-rating')
      )
    return false