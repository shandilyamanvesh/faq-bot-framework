class AddFacebookFlagToKnowledgeBases < ActiveRecord::Migration[5.1]
  def change
  	add_column :knowledge_bases, :allow_facebook_messenger_access, :boolean
  end
end
