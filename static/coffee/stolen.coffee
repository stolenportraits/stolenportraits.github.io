setHeights = ->
  previews = [0 .. $('.preview').length - 1]
  $('.preview')[i].style.height = $('.preview img')[i].height + 'px' for i in previews


$(document).ready ->
  setHeights()