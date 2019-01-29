App.knowledge_basis_info = App.cable.subscriptions.create "KnowledgeBasisInfoChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
  	res = window.location.pathname.match(/^\/knowledge_bases\/(\d+)/)
  	if res != null && res.length == 2
      knowledge_basis_id = res[1]
      # check if user currently has opened the respective knowledge basis
      if parseInt(data["knowledge_basis_id"]) == parseInt(knowledge_basis_id)
        # update counters
        unmatched_count = parseInt(data["unmatched_questions_count"])
        matched_count = parseInt(data["matched_questions_count"])
        total_count = unmatched_count + matched_count
        $("title").html("(" + total_count + ") FAQ Bot Framework")
        $("#unanswered_questions_badge").text(total_count).show()
        if matched_count > 0
          $("#matched_questions_badge").text(matched_count).show()
        else
          $("#matched_questions_badge").hide()
        if unmatched_count > 0
          $("#unmatched_questions_badge").text(unmatched_count).show()

        # new question from user
        if data["target"] == "#matched_questions" || data["target"] == "#unmatched_questions"
          $("#no_questions").hide()
          $(data["target"]).show().append(data["partial"])
          $('select.select2').select2(
            maximumSelectionSize: 1
            placeholder: 'Select existing answer').on 'select2:select', (e) ->
            $(this).parents('form').submit()
            return

        # question confirmed by user
        else
          $(data["target"]).hide()
          if total_count == 0
            $("#no_questions").show()
          if matched_count == 0
            $("#matched_questions").hide()