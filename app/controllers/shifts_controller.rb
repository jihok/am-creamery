class ShiftsController < ApplicationController
  before_filter :check_login
  authorize_resource

  def index
    @shifts = Shift.incomplete.chronological.paginate(:page => params[:page]).per_page(10)
    @completed_shifts = Shift.completed.chronological.paginate(:page => params[:page]).per_page(10)
  end

  def show
    @shift = Shift.find(params[:id])
    authorize! :read, @shift
    # get the jobs worked on this shift (upon completion)
    @jobs = Array.new
  end

  def new
    if params[:from].nil?
      if params[:id].nil?
        @shift = Shift.new
        authorize! :new, @shift
      else
        @shift = Shift.find(params[:id])
      end
    else
      @shift = Shift.new
      authorize! :new, @shift
      @shift.assignment_id = params[:id]
    end
  end

  def edit
    @shift = Shift.find(params[:id])
    authorize! :edit, @shift
  end

  def create
    @shift = Shift.new(params[:shift])
    authorize! :create, @shift
    if @shift.save
      # if saved to database
      flash[:notice] = "Successfully created shift."
      redirect_to @shift # go to show shift page
    else
      # return to the 'new' form
      render :action => 'new'
    end
  end

  def update
    @shift = Shift.find(params[:id])
    authorize! :update, @shift
    if @shift.update_attributes(params[:shift])
      flash[:notice] = "Successfully updated shift."
      redirect_to @shift
    else
      render :action => 'edit'
    end
  end

  def destroy
    @shift = Shift.find(params[:id])
    authorize! :destroy, @shift
    @shift.destroy
    flash[:notice] = "Successfully removed shift from the AMC system."
    redirect_to shifts_url
  end
end
