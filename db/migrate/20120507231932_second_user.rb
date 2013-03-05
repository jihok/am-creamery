class SecondUser < ActiveRecord::Migration
  def up
  	man = User.new
  	man.email = "man@example.com"
  	man.password = "secret"
  	man.password_confirmation = "secret"
  	man.employee_id = 3
  	man.save!
  end

  def down
  	man = User.find_by_email "man@example.com"
  	User.delete man
  end
end
