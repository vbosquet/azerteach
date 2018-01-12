$(document).ready(function() {
  $(document).on( 'click', 'a.delete-record', function() {
  	if(confirm("Confirmer la suppression?")) {
  		var row = $(this).closest("tr").get(0);
		
  		var id = $(this).attr('data-id');
  		var type = $(this).attr('data-type');
		
  		$.ajax({
  		  type: 'POST',
  		  url: '/admin/' + type + '/' + id,
  		  data: '_method=delete',
  		  complete: function(xhr, statusText) {
  		  	if(xhr.status == 200) {
  					var oTable = $('#'+type+'-datatable').dataTable();
  					oTable.fnDeleteRow(oTable.fnGetPosition(row));
  		    }
  		  }
  		});
  	}
	
  	return false;
  });
});