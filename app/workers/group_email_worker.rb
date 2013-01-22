class GroupEmailWorker
  @queue = :group_email

  def self.perform(email_id)
    email = Email.find(email_id)
    users = User.where(:role => email.role)
    
    email.update_attribute(:started_at, Time.now)
    email.update_attribute(:total_recipients, users.count)

    users.each_with_index do |user, index|
      puts "Sending email '#{email.subject}' to #{user.email}..."
      begin
        UserMailer.group_message(email, user.email).deliver
        email.update_attribute(:total_sent, index + 1)
      rescue => e
        puts "Sending email '#{email.subject}' to #{user.email} errored with exception #{e}."
      end
    end

    email.update_attribute(:ended_at, Time.now)
  end
end