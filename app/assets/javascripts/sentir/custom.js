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

  $('#student-select').on('change', function() {
      var studentId = $(this).val();
      var invoiceId = $(this).data('invoice');
      $.ajax({
          type: 'GET',
          url: '/admin/update_lessons_select',
          dataType: "json",
          data: {student_id: studentId, invoice_id: invoiceId},
          complete: function(result) {
              data = result.responseJSON;

              $('#lessons-select').empty();
              $("#lessons-select").prop("disabled", false);
              $("#all-lessons-checkbox").prop("checked", false);
              $("#amount-without-vat").val(0.0);
              $("#vat-select").find($('option')).attr('selected', false);
              $("#amount-with-vat").val(0.0);

              if (typeof data !== 'undefined' && data.lessons.length > 0) {
                  for(var i = 0; i < data.lessons.length; i++) {
                      var option = '<option ';
                      var productName = "";
                      
                      for(var j = 0; j < data.products.length; j++) {
                          if (data.products[j].id === data.lessons[i].product_id) {
                              productName = data.products[j].name;
                          }
                      }

                      if(data.selected_lessons != null) {
                        for(var j = 0; j < data.selected_lessons.length; j++) {
                          if (data.selected_lessons[j].id == data.lessons[i].id) {
                            option = option + 'selected="selected" ';
                          }
                        }
                      }

                      $('#lessons-select').append(option + 'value="' + data.lessons[i].id + '">' + productName + ' - '
                          + moment(data.lessons[i].start_date).format("DD/MM/YYYY") + '</option>');
                  }
              }
          }
      });
  });

  var calculateTotalAmount = function (lessonIds) {
      $.ajax({
          type: 'GET',
          url: '/admin/calculate_total_amount',
          dataType: "json",
          data: {lesson_ids: lessonIds},
          complete: function(result) {
              $("#amount-without-vat").val(result.responseJSON.total_amount);
          }
      });
  };

  var calculateAmountWithVat = function () {
      if ($("#vat-select").val() !== '') {
          var vat = parseInt($("#vat-select").val());
          var amount = parseInt($("#amount-without-vat").val());
          var amountWithVat = amount + (amount * vat/100);
          $("#amount-with-vat").val(Number(amountWithVat).toFixed(2));
      }
  };

  $("#all-lessons-checkbox").on('change', function() {
      var lessonIds = [];
      if($(this).prop("checked")) {
          $("#lessons-select").prop("disabled", true);
          $("#lessons-select").find($('option')).attr('selected', false).each(function() {
              lessonIds.push($(this).val());
          });
          calculateTotalAmount(lessonIds);
          calculateAmountWithVat();
      } else {
          $("#lessons-select").prop("disabled", false);
          $("#amount-without-vat").val(0.0);
          $("#vat-select").find($('option')).attr('selected', false);
          $("#amount-with-vat").val(0.0);
      }
  });

  $("#lessons-select").on('change', function () {
      var lessonIds = [];
      $("#lessons-select").find($('option:selected')).each(function() {
          lessonIds.push($(this).val());
      });
      calculateTotalAmount(lessonIds);
  });

  $("#vat-select").on('change', function () {
      calculateAmountWithVat();
  });

});