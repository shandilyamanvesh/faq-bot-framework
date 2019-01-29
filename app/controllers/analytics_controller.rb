class AnalyticsController < ApplicationController
  def index
    @knowledge_basis = KnowledgeBasis.find(params[:knowledge_basis_id])
    @answers = @knowledge_basis.answers

    @data = {
        labels: ["Instantly", "Within 5 minutes", "Within 30 minutes", "Within 1 day", "Answer pending"],
        datasets: [
          {
              label: "Response time",
              data: [@knowledge_basis.questions.reply_time_between(0, 1).count,
              	@knowledge_basis.questions.reply_time_between(1,5).count,
              	@knowledge_basis.questions.reply_time_between(5,30).count,
              	@knowledge_basis.questions.reply_time_between(30,1440).count,
              	@knowledge_basis.questions.unanswered.count
               ]
          }    
        ]
      }

      @options =  { 
        scales: {
          yAxes: [{
            ticks: {
              stepSize: 1
            }
          }]
        }
      }
  end
end
