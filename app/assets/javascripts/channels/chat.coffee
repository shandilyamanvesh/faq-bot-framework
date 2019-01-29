App.chat = App.cable.subscriptions.create "ChatChannel",
  connected: ->
    # Called when the subscription is ready for use on the server
    $("#chat_form button[type='submit']").prop("disabled", false)

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
  	# Called when there's incoming data on the websocket for this channel
    if data["type"] == "answer"
      div = $("<div/>", {class: "alert alert-info", style: "margin-right: 20px"})
      div.html(data['message'].linkify({target: "_blank"}))
      $("#messages").append(div)
    if data["type"] == "question"
      $("#messages").append($("<div/>", {class: "alert alert-success", style: "margin-left: 20px", text: data['message']});)
    if data["type"] == "buttons"
      # feedback loop question
      $("#messages").append($("<div/>", {class: "alert alert-info", style: "margin-right: 20px", text: data['data']['message']});)
      
      # feedback loop buttons
      div = $("<div/>", {style: "padding-bottom: 20px"})
      $(data['data']['options']).each ( index, object ) =>
        button = $("<button>" + object['label'] + "</button>").attr({ class: "btn btn-outline-info", style: "margin-right: 10px", onclick: "sendButton('" + data['data']['question_id'] + "', " + object['useful'] + ")" })
        div.append(button)
      $("#messages").append(div)
      
    window.scrollTo(0,document.body.scrollHeight)

  ask: (message, knowledge_basis_id) ->
    @perform 'ask', message: message, knowledge_basis_id: knowledge_basis_id

  feedback: (question_id, useful) ->
    @perform 'feedback', question_id: question_id, useful: useful