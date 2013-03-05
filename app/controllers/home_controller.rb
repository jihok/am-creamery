class HomeController < ApplicationController
  def index
    @stores = Store.active.alphabetical.paginate(:page => params[:page]).per_page(10)
    if logged_in?
      @employee = Employee.find_by_id(current_user.employee_id)
      @completed_shifts = Shift.completed.chronological.paginate(:page => params[:page]).per_page(10)
      @upcoming_shifts = Shift.for_next_days(14).paginate(:page => params[:page]).per_page(10)
      @past_shifts = Shift.for_past_days(14).paginate(:page => params[:page]).per_page(10)
      @current_assignments = Assignment.current.for_store(current_user.employee.current_assignment.store_id).paginate(:page => params[:page]).per_page(10)
      @admin_current_assignments = Assignment.current.paginate(:page => params[:page]).per_page(10)
      @today_shifts = Shift.for_next_days(0).chronological.paginate(:page => params[:page]).per_page(10)
      @employees = Employee.active.alphabetical.paginate(:page => params[:page]).per_page(10)
    end
  end

  def about
  end

  def contact
  end

  def privacy
  end
  
  def search
    @query = params[:query]
    @employees = Employee.search(@query)
    @stores = Store.search(@query)
    @total_hits = @employees.size + @stores.size
  end

end