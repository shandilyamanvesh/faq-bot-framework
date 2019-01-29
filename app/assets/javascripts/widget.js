function sendMessage() {
	var msg = $('#message').val();
	if (msg != '') {
		App.chat.ask(msg, $('#knowledge_basis_id').val());
		$('#message').val('');
	}
}

function sendButton(question_id, useful) {
	if (question_id != '') {
		App.chat.feedback(question_id, useful);
	}
}

$( document ).ready(function() {
	$("#submit").bind("click", function(event, xhr, status){
		sendMessage();
    });

    $("#message").keypress(function (e) {
  		if (e.which == 13) {
  			sendMessage();
  			return false;
  		}
  	});
});
