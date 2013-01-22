class Email < ActiveRecord::Base
  attr_accessible :subject, :body, :total_sent, :role

  validates :subject, :presence => true,
                      :length => { :in => 1..78 }
  validates :body,    :presence => true,
                      :length => { :minimum => 5 }
  validates :role,    :presence => true

  def deliver
    Resque.enqueue(GroupEmailWorker, self.id)
  end

  def estimated_send_rate
    now = Time.now
    return 0 if started_at.blank? || now - started_at == 0
    (total_sent / (now - started_at)).round
  end

  def estimated_completion_str
    now = Time.now
    return "Never" if started_at.blank? ||
                      now - started_at == 0 ||
                      total_sent / (now - started_at) == 0
    seconds_left = ((total_recipients - total_sent) / (total_sent / (now - started_at)))
    hours = seconds_left / 3600
    minutes = seconds_left / 60
    "#{sprintf('%02d', hours)}:#{sprintf('%02d', minutes)}"
  end

  def total_remaining
    total_recipients - total_sent
  end

  def done?
    total_sent == total_recipients && !started_at.blank?
  end
end
