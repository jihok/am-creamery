class User < ActiveRecord::Base
  # Use built-in rails support for password protection
  has_secure_password
  attr_accessible :employee_id, :password, :password_confirmation, :email
  
  # Relationship
  belongs_to :employee
  
  # Validations
  validates_uniqueness_of :email
  validates_format_of :email, :with => /^[\w]([^@\s,;]+)@(([\w-]+\.)+(com|edu|org|net|gov|mil|biz|info))$/i, :message => "is not a valid format"
  validate :employee_is_active_in_system
  
  def self.authenticate(email, password)
    find_by_email(email).try(:authenticate, password)
  end

  ROLES = [['Administrator', :admin],['Manager', :manager],['Employee', :employee]]

  def role?(authorized_role)
    role = Employee.active.find_by_id(self.employee_id).role unless Employee.active.find_by_id(self.employee_id).nil?
    return false if role.nil?
    role.downcase.to_sym == authorized_role
  end

  private
  def employee_is_active_in_system
    all_active_employees = Employee.active.all.map{|e| e.id}
    unless all_active_employees.include?(self.employee_id)
      errors.add(:employee_id, "is not an active employee at the creamery")
    end
  end
  
end
