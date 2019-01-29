class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  delegate :can?, :cannot?, :to => :ability

  ROLES = %i[admin manager]

  scope :admin, -> { where(role: "admin") }

  has_and_belongs_to_many :knowledge_bases
  has_many :questions, foreign_key: :assigned_by
  has_many :answers, foreign_key: :created_by

  def ability
    @ability ||= Ability.new(self)
  end

  def knowledge_bases
    if role == "admin"
      KnowledgeBasis.all
    else
      super
    end
  end

  def to_s
  	email
  end

end
