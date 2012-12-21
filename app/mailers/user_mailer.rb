class UserMailer < ActionMailer::Base
  MASS_EMAIL_STEPPING = 50
  default from: "no-reply@lag.tv"

  def password_reset(user)
    @user = user
    mail :to => user.email, :subject => "Password Reset for LAGTV Website"
  end

  def group_message(email)
    begin
      email.update_attribute(:started_at, Time.now)
      count = 0
      scope = User.scoped
      email.role_list.each{ |r| scope.send(r) }
      total_users = scope.count

      email.update_attribute(:total_recipients, total_users)
      email.update_attribute(:ended_at, Time.now) if total_users == 0

      while(count < total_users) do
        email.update_attribute(:total_sent, count)
        users = scope.order(:id).limit(MASS_EMAIL_STEPPING).offset(count)
        users.each do |u|
          mail :to => u.email, :subject => email.subject do |format|
            format.text { render :text => email.body }
          end
          count += 1
        end
      end
      email.update_attribute(:ended_at, Time.now) if count == total_users
    rescue => e
      logger.fatal "Sending of group_message halted with exception #{e}. Count is: #{count}"
    end
    email.update_attribute(:total_sent, count)
  end
end