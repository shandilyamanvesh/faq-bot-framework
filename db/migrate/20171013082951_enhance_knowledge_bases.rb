class EnhanceKnowledgeBases < ActiveRecord::Migration[5.1]
  def change
  	add_column :knowledge_bases, :allow_anonymous_access, :boolean, default: false
  	add_column :knowledge_bases, :hash_id, :string
  	KnowledgeBasis.all.each do |kb|
  		kb.hash_id = SecureRandom.urlsafe_base64
  		kb.save
  	end
  end
end
