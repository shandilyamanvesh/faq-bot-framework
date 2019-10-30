require 'roo'

class ImportJob < ApplicationJob
  queue_as :default

  # after_enqueue do |job|
  #  stream_id = "classifier_info_channel_#{arguments.second}"
  #  ActionCable.server.broadcast(stream_id, message: "import_scheduled")
  # end

  # after_perform do |job|
  #  stream_id = "classifier_info_channel_#{arguments.second}"
  #  ActionCable.server.broadcast(stream_id, message: "import_completed")
  # end

  def perform(knowledge_basis_id, original_filename, current_user_id)
    count = 0
    CustomLogger.log("Import answers", namespace: "Import") do |logger|

      begin
        knowledge_basis = KnowledgeBasis.find(knowledge_basis_id)
        xlsx = Roo::Spreadsheet.open(Rails.root.join('tmp', original_filename).to_s)
        sheet = xlsx.sheet(0)
        ((sheet.first_row)..sheet.last_row).each do |i|
          # question in first column
          q = ActionView::Base.full_sanitizer.sanitize(sheet.cell(i, 1)).truncate(65535)
          # answer in second column
          a = ActionView::Base.full_sanitizer.sanitize(sheet.cell(i, 2)).truncate(65535)
          b = ActionView::Base.full_sanitizer.sanitize(sheet.cell(i, 3)).truncate(65535)
          next if a.blank? # skip if line empty
          question = Question.new(text: q, knowledge_basis: knowledge_basis, confirmed_at: DateTime.now)
          answer = knowledge_basis.answers.where(text: a).first_or_create
          answer.created_by = current_user_id if answer.new_record?
          answer.questions.push(question)
          count +=1 if answer.save
        end
      rescue Exception => e
        logger.add_error e
        logger.set_alert_level 2
      end
    end
  end
end
