class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new(:role => :guest) # for guest
    send(@user.role)
  end

  def guest
    can :create, Report
  end

  def general
    guest
    can :manage, User, :id => @user.id
    cannot :destroy, User

    # Tag
    can :read, Tag, Tag.readable(@user)

    # Deployment
    can :read, ReceiverDeployment, ReceiverDeployment.readable(@user)
    can :manage, ReceiverDeployment, ReceiverDeployment.managable(@user)

    # TagDeployment
    can :read, TagDeployment, TagDeployment.readable(@user)
    can :manage, TagDeployment, TagDeployment.managable(@user)

    can :read, Study
    can :manage, Study, Study.includes(:collaborators) do |s|
      s.user_id == @user.id || s.collaborators.select({ :role => 'manage' }).map(&:user).include?(@user)
    end
    cannot :destroy, Study
  end

  def researcher
    general
    can :read, Report
  end

  def investigator
    researcher
    can :read,   Receiver
    can :create, Study
    can :create, Submission
    can :read,   Submission, :user_id => @user.id
  end

  def admin
    can :read,   ActiveAdmin
    can :manage, :all
  end

end
