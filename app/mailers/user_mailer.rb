class UserMailer < ActionMailer::Base
  MASS_EMAIL_STEPPING = 50
  default from: "no-reply@lag.tv"

  def password_reset(user)
    @user = user
    mail :to => user.email, :subject => "Password Reset for LAGTV Website"
  end

  def group_message(email, recipient_address)
    mail :to => recipient_address, :subject => email.subject do |format|
      format.text { render :text => email.body }
    end
  ensure
    email.update_attribute(:total_sent, count)
  end
end