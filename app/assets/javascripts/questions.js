$( document ).ready(function() {
	$( "select.select2#question_answer_id" ).select2({
    	maximumSelectionSize: 1,
    	placeholder: "Select existing answer",
	}).on("select2:select", function(e) {
		$(this).parents("form").submit();
	});
});
