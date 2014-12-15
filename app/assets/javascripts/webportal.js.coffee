# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('#tableTickets').dataTable( {
    "sScrollX": "100%",
    "sScrollY": "500",
    "iDisplayLength": 25,
    "bScrollCollapse": true
  });
jQuery ->
  $('#tableMembers').dataTable( {
    "sScrollX": "100%",
    "sScrollY": "500",
    "iDisplayLength": 10,
    "bScrollCollapse": true
  }) ;
jQuery ->
  $('#tableOverview').dataTable( {
    "sScrollX": "100%",
    "sScrollY": "400",
    "iDisplayLength": 25,
    "bScrollCollapse": true
  }) ;
jQuery ->
  $('#tableFile').dataTable( {
    "sScrollX": "100%",
    "sScrollY": "500",
    "iDisplayLength": 25,
    "bScrollCollapse": true
  }) ;  