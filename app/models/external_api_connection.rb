class ExternalApiConnection < ApplicationRecord
  attr_encrypted :oauth2_client_secret, key: Rails.application.secrets.attr_encrypted_encryption_key
	validates :name, presence: true, uniqueness: { scope: :knowledge_basis_id }
	validates :url, presence: true
  belongs_to :knowledge_basis
	has_many :external_api_connection_placeholder_embeddings
  has_many :placeholders, through: :external_api_connection_placeholder_embeddings, dependent: :destroy

  accepts_nested_attributes_for :placeholders, allow_destroy: true

  before_save :update_placeholders, if: :url_changed?

  # destroy placeholder(s) that are not associated to any other external api connections
  before_destroy {|record| record.placeholders.select{|p| p.external_api_connections.count == 1}.map{|p| p.destroy} }

  def update_placeholders
    placeholder_names = url.scan(/\[\[(\w+?)\]\]/).flatten.uniq
    
    # cleanup outdated placeholder associations
    placeholder_names.blank? ? placeholders.destroy_all : placeholders.where("name NOT IN (?)", placeholder_names).destroy_all

    # create newly added placeholders
    (placeholder_names - placeholders.map(&:name)).each do |placeholder_name|
      if (p = Placeholder.where(name: placeholder_name, knowledge_basis: knowledge_basis).first)
        placeholders << p
      else
        placeholders.build(name: placeholder_name, knowledge_basis: knowledge_basis)
      end
    end
  end

  def enriched_url(user_session)
    request = url
    placeholders.each do |p|
      request.gsub!("[[#{p.name}]]", p.value(user_session).to_s)
    end
    request
  end

  def enriched_response(user_session_data_hash)
    hash_response = JSON.parse(user_session_data_hash) rescue {}
    response = response_template
    hash_placeholders = response_template.scan(/response(\[\S+\])/).flatten.uniq
    if hash_placeholders.count > 0
      hash_placeholders.each do |hash_placeholder|
        # extract hash keys from string and typecast
        keys = hash_placeholder.scan(/\[(\S+?)\]/).flatten.map{|key| !!(key =~ /["']\S+?["']/) ? key.scan(/["'](\S+?)["']/).first : key.to_i}.flatten
        # replace placeholders with values
        value = hash_response.dig(*keys) rescue "[...]"
        response.gsub!("response#{hash_placeholder}", value)
      end
      response
    # response template malformed, output JSON string
    else
      user_session_data_hash.to_s
    end

  end

  def contains_unmatched_placeholders?
    placeholders.map{|p| p.replaceable.blank?}.include?(true)
  end

  def get_oauth2_token
    client = OAuth2::Client.new(oauth2_client_id, oauth2_client_secret, token_url: oauth2_token_url)
    encrypted_credentials = "Basic " + Base64.encode64("#{oauth2_client_id}:#{oauth2_client_secret}")
    client.client_credentials.get_token(headers: {'Authorization': encrypted_credentials }, scope: oauth2_scope)
  end

  def oauth_authenticated?
    oauth2_token_url.present?
  end
end
