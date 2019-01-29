function updatePlaceholderSelect(element) {
	var replaceable_id = element.value || "empty"
	$(element).closest('tr').find('td.replaceable-select').hide();
	$(element).closest('tr').find('select.replaceable-select').prop('disabled', true);
	$(element).closest('tr').find('td.' + replaceable_id).show();
	$(element).closest('tr').find('select.'+ replaceable_id).prop('disabled', false);
}