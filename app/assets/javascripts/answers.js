function confirmQuestion(element) {
	var tr = $(element).closest('tr');
	tr.find('input.confirmed_at').val(new Date($.now()));
	tr.find('td.unmatch').hide();
	tr.find('td.confirm').hide();
	$('tbody.training').append(tr);
	// update badges
	var matched_count = Number($('span.badge.matched').text()) - 1;
	$('span.badge.matched').text(matched_count);
	var training_count = Number($('span.badge.training').text()) + 1;
	$('span.badge.training').text(training_count);
	if (matched_count == 0) {
		$('.matched.empty.alert').show();
	}
}

function unmatchQuestion(element) {
	var tr = $(element).closest('tr');
	tr.find('input.answer-id').val('');
	tr.hide();
	// update badges
	var matched_count = Number($('span.badge.matched').text()) - 1;
	$('span.badge.matched').text(matched_count);
	if (matched_count == 0) {
		$('.matched.empty.alert').show();
	}
}

function deleteQuestion(element) {
	var tab = $(element).closest('div.tab-pane').attr('id');
	// update badges
	var count = Number($('span.badge.' + tab).text()) - 1;
	$('span.badge.' + tab).text(count);
	if (count == 0) {
		$('.empty.alert.' + tab).show();
	}
}

function updatePlaceholderSelect(element) {
	var replaceable_id = element.value || "empty"
	$(element).closest('tr').find('td.replaceable-select').hide();
	$(element).closest('tr').find('select.replaceable-select').prop('disabled', true);
	$(element).closest('tr').find('td.' + replaceable_id).show();
	$(element).closest('tr').find('select.'+ replaceable_id).prop('disabled', false);
}