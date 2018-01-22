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

  $('#start-date, #end-date').datepicker({
  });

  $('#student-select').on('change', function() {
      var studentId = $(this).val();
      var invoiceId = $(this).data('invoice');
      $.ajax({
          type: 'GET',
          url: '/admin/invoice/update_lessons_select',
          dataType: 'json',
          data: {student_id: studentId, invoice_id: invoiceId},
          complete: function(result) {
              data = result.responseJSON;

              $('#student-lessons-select').empty();
              $("#all-lessons-checkbox").prop("checked", false);
              $("#amount-without-vat").val(0.0);
              $("#vat-select").find($('option')).attr('selected', false);
              $("#amount-with-vat").val(0.0);

              if (typeof data !== 'undefined' && data.lessons.length > 0) {
                  for(var i = 0; i < data.lessons.length; i++) {
                      var option = '<option ';
                      //var productName = "";
                      
                      /*for(var j = 0; j < data.products.length; j++) {
                          if (data.products[j].id === data.lessons[i].product_id) {
                              productName = data.products[j].name;
                          }
                      }*/

                      if(data.selected_lessons != null) {
                        for(var j = 0; j < data.selected_lessons.length; j++) {
                          if (data.selected_lessons[j].id == data.lessons[i].id) {
                            option = option + 'selected="selected" ';
                          }
                        }
                      }

                      $('#student-lessons-select').append(option + 'value="' + data.lessons[i].id + '">' + data.lessons[i].item_sold + ' - '
                          + moment(data.lessons[i].invoice_date).format("DD/MM/YYYY") + '</option>');
                  }
              }
          }
      });
  });

  var calculateTotalAmount = function (lessonIds, action) {
    var url = '';
    if (action === 'student') {
      url = '/admin/invoice/calculate_total_amount';
    } else if (action === 'teacher') {
      url = '/admin/expense_export/calculate_total_amount';
    }

    $.ajax({
          type: 'GET',
          url: url,
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
      var action = $(this).data('action');

      if($(this).prop("checked")) {
          $("#student-lessons-select, #teacher-lessons-select").find($('option')).each(function() {
              $(this).prop('selected', true);
              lessonIds.push($(this).val());
          });

          calculateTotalAmount(lessonIds, action);
          calculateAmountWithVat();

      } else {
          $("#student-lessons-select, #teacher-lessons-select").find($('option')).prop('selected', false)
          $("#amount-without-vat").val(0.0);
          $("#vat-select").find($('option')).attr('selected', false);
          $("#amount-with-vat").val(0.0);
      }
  });

  $("#student-lessons-select, #teacher-lessons-select").on('change', function () {
      var lessonIds = [];
      var action = $('#all-lessons-checkbox').data('action');
      $(this).find($('option:selected')).each(function() {
          lessonIds.push($(this).val());
      });
      calculateTotalAmount(lessonIds, action);
  });

  $("#vat-select").on('change', function () {
      calculateAmountWithVat();
  });

  $("#teacher-select").on('change', function () {
    var teacherId = $(this).val();
    var expenseExportId = $(this).data('expense-export');
    $.ajax({
          type: 'GET',
          url: '/admin/expense_export/update_lessons_select',
          dataType: 'json',
          data: {teacher_id: teacherId, expense_export_id: expenseExportId},
          complete: function(result) {
              data = result.responseJSON;
              $('#teacher-lessons-select').empty();
              $("#all-lessons-checkbox").prop("checked", false);
              $("#amount-without-vat").val(0.0);

              if (typeof data !== 'undefined' && data.lessons.length > 0) {
                  for(var i = 0; i < data.lessons.length; i++) {
                      var productName = "";
                      
                      for(var j = 0; j < data.products.length; j++) {
                          if (data.products[j].id === data.lessons[i].product_id) {
                              productName = data.products[j].name;
                          }
                      }
                      $('#teacher-lessons-select').append('<option value="' + data.lessons[i].id + '">' + productName + ' - '
                          + moment(data.lessons[i].start_date).format("DD/MM/YYYY") + '</option>');
                  }
              }
          }
      });
  });

});