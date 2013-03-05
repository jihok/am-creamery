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
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    user ||= User.new

    if user.role? :admin
        # god-like powers in the system and can do anything
        can :manage, :all
    elsif user.role? :manager
        # edit information on themselves and any employee assigned to their store 
        can :read, Employee do |e|
            my_store = user.employee.current_assignment.store_id
            my_store == e.current_assignment.store_id
        end

        can :update, Employee do |e|
            my_store = user.employee.current_assignment.store_id
            my_store == e.current_assignment.store_id
        end

        # they can also create and edit shifts (and associated jobs)
        can :show, Store
        can :show, Shift
        can :create, Shift

        can :update, Shift do |s|
            my_store = user.employee.current_assignment.store_id
            my_store == s.assignment.store_id
        end

        can :destroy, Shift do |s|
            my_store = user.employee.current_assignment.store_id
            my_store == s.assignment.store_id
        end

        #can :create, ShiftJob
        #can :update, ShiftJob
        can :create, Job
        can :update, Job
        can :show, Job

    elsif user.role? :employee
        # see their own information, and have read-only access
        can :show, Employee do |e|
            e == user.employee
        end

        can :show, Shift do |s|
            user.employee.current_assignment.shifts.include? s
        end

        can :show, Store
    else
        can :show, Store
    end
  end
end