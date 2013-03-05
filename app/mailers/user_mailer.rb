class UserMailer < ActionMailer::Base
  default from: "holyji@gmail.com"

  def new_user_msg(user)
  	@user = user
  	mail(:to => user.email, :subject => "Thanks for Creating an account!")
  end
end
