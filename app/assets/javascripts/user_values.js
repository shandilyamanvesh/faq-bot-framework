$(document).ready(function() {
	$("#user_value_data_type").change(function() {
		$("#body_input").toggle(this.value == "regex");
		$("#user_value_regular_expression").val("");
	});
});
