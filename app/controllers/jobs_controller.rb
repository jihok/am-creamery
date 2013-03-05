class JobsController < ApplicationController
  before_filter :check_login
  authorize_resource

  def index
    @jobs = Job.active.alphabetical.paginate(:page => params[:page]).per_page(10)
    @inactive_jobs = Job.inactive.alphabetical.paginate(:page => params[:page]).per_page(10)
  end

  def show
    @jobs = Job.active.alphabetical.paginate(:page => params[:page]).per_page(10)
    @inactive_jobs = Job.inactive.alphabetical.paginate(:page => params[:page]).per_page(10)
    #@job = Job.find(params[:id])
    # get all the current jobs
    #@current_assignments = @job.assignments.current.by_employee.paginate(:page => params[:page]).per_page(8)
  end

  def new
    @job = Job.new
    authorize! :new, @job
  end

  def edit
    @job = Job.find(params[:id])
    authorize! :edit, @job
  end

  def create
    @job = Job.new(params[:job])
    authorize! :create, @job
    if @job.save
      # if saved to database
      flash[:notice] = "Successfully created #{@job.name}."
      redirect_to @job # go to show job page
    else
      # return to the 'new' form
      render :action => 'new'
    end
  end

  def update
    @job = Job.find(params[:id])
    authorize! :update, @job
    if @job.update_attributes(params[:job])
      flash[:notice] = "Successfully updated #{@job.name}."
      redirect_to @job
    else
      render :action => 'edit'
    end
  end

  def destroy
    @job = Job.find(params[:id])
    authorize! :destroy, @job
    @job.destroy
    flash[:notice] = "Successfully removed #{@job.name} from the AMC system."
    redirect_to jobs_url
  end
end
