class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
    
    if user.role == "admin"
      can :manage, :all
    else
      can :read, :all
      can [:read, :edit, :update, :train, :export, :clear_dashboard], KnowledgeBasis, id: user.knowledge_bases.map(&:id)
      can [:edit, :update], User, id: user.id
      can [:read, :edit, :update, :create, :destroy], Answer, knowledge_basis_id: user.knowledge_bases.map(&:id)
      can :manage, Question, knowledge_basis_id: user.knowledge_bases.map(&:id)
      can :manage, GlobalValue, knowledge_basis_id: user.knowledge_bases.map(&:id)
    end
    if user.role == "manager"
      can :import, Answer
      can :reset, KnowledgeBasis, id: user.knowledge_bases.map(&:id)
    end
  end
end
