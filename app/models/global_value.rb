class GlobalValue < ApplicationRecord
	belongs_to :knowledge_basis
	validates :name, presence: true, uniqueness: { scope: :knowledge_basis_id }
	validates :value, presence: true
	has_many :placeholders, as: :replaceable
end
