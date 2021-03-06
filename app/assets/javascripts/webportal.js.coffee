# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/



jQuery ->
  $('#tableTickets').dataTable( {
    "sScrollX": "100%",
    "sScrollY": "800",
    "iDisplayLength": 25,
    "bScrollCollapse": true,
    "columns": [{ "width": "10%"},{"width": "38%"},{"width": "5%"},{"width": "10%"},{"width": "10%"},{"width": "10%"},{"width": "10%"}]
  });
jQuery ->
  $('#tableAttendes').dataTable( {
    "sScrollX": "100%",
    "sScrollY": "100%",
    "iDisplayLength": -1,
    "bScrollCollapse": true,
    "paging": false,
    "searching": false
  }); 
jQuery ->
  $('#tablePages').dataTable( {
    "sScrollX": "100%",
    "sScrollY": "100%",
    "iDisplayLength": -1,
    "bScrollCollapse": true,
    "paging": false,
    "dom": '<"pull-left"f><"pull-right"l>tip'
  });
jQuery ->
  $('#tableMembers').dataTable( {
    "sScrollX": "100%",
    "sScrollY": "100%",
    "paging": false,  
    "bScrollCollapse": false
  }) ;
jQuery ->
  $('#tableOverview').dataTable( {
    "sScrollX": "100%",
    "sScrollY": "100%",
    "iDisplayLength": 25,
    "paging":true,
    "bScrollCollapse": true
  }) ;
jQuery ->
  $('#tableFile').dataTable( {
    "sScrollX": "100%",
    "sScrollY": "100%",
    "paging":false,
    "bScrollCollapse": true
  });  
jQuery ->
  $('#tableTools').dataTable( {
    "sScrollX": "100%",
    "sScrollY": "100%",
    "paging":false,
    "bScrollCollapse": true,
    "columns": [{ "width": "10%"},{"width": "30%"},{"width": "10%"},{"width": "20%"},{"width": "20%"},{"width": "2%"}]
  });  
jQuery ->
  $('#tableDataFileShow').dataTable( {
    "sScrollX": "100%",
    "paging":false,
    "bScrollCollapse": true
  });
jQuery ->
  $('#wikitable').treetable({ 
    expandable: true 
  });
jQuery ->
  $('#tablePublications').dataTable( {
    "sScrollX": "100%",
    "sScrollY": "100%",
    "paging":false,
    "bScrollCollapse": true,
    "columns": [{ "width": "10%"},{"width": "25%"},{"width": "25%"},{"width": "8%"},{"width": "10%"},{"width": "12%"},{"width": "2%"}]
  });  
      