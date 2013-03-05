class ThirdUser < ActiveRecord::Migration
  def up
  	emp = User.new
  	emp.email = "emp@example.com"
  	emp.password = "secret"
  	emp.password_confirmation = "secret"
  	emp.employee_id = 12
  	emp.save!
  end

  def down
  	emp = User.find_by_email "emp@example.com"
  	User.delete emp
  end
end
