$(document).ready ->
  $('audio').on 'ended', ->
    nextTrack = $(this).parent().next('li').find('audio').get(0);
    if nextTrack 
      nextTrack.play();
