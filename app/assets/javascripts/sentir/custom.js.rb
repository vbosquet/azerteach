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

  $('#start-date, #end-date').datetimepicker({
      locale: 'fr'
  });

  $('#lessons-select').on('change', function() {
      var studentId = $("#student-select").val();
      $.ajax({
          type: 'GET',
          url: '/admin/update_lessons_select',
          dataType: "json",
          data: {student_id: studentId},
          complete: function(result) {
              console.log("OK");
          }
      });
  });
});