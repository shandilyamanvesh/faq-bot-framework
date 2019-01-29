App.classifier_info = App.cable.subscriptions.create "ClassifierInfoChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
  	# Called when there's incoming data on the websocket for this channel
    if data["message"] == "training_scheduled"
      $("#train_classifier_button").prop('disabled', true)
    else if data["message"] == "training_started"
  	  $("#train_classifier_button").prop('value', 'Training ...');
    else if data["message"] == "training_completed"
      $("#train_classifier_button").prop('value', 'Train classifier now!');
      $("#train_classifier_button").prop('disabled', false);


