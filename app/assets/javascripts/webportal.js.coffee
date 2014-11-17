# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('#tableTickets').dataTable( {
    "sScrollX": "100%",
    "sScrollY": "500",
    "iDisplayLength": 50,
    "bScrollCollapse": true
  })
  $('#tableMembers').dataTable( {
    "sScrollX": "100%",
    "sScrollY": "500",
    "iDisplayLength": 50,
    "bScrollCollapse": true
  }) ;