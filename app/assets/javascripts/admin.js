// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui/widgets/sortable
//= require admin/bootstrap
//= require admin/file-input/bootstrap.file-input
//= require chosen-jquery
//= require admin/chosen_setup
//= require admin/modal

$( document ).ready(function() {
  $( function() {
    $( "table.sortable tbody" ).sortable( {
      stop: function (e, ui) {
	obj = {};

	$('table.sortable tbody tr').each(function (i) {
	  var id = $(this).data('id');
	  obj[id] = i;
	})
	
	$.ajax({
	  method: 'POST',
	  url: '/admin/items/sort',
	  data: { order: obj }
	})
      },
    });
  });
});
