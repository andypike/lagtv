module EmailsHelper
  def remaining_str(email)
    if email.started_at.blank?
      "Unknown"
    else
      email.total_remaining
    end
  end

  def status(email)
    if email.done?
      "Done"
    elsif email.started_at.blank?
      "Not Started"
    else
      "Processing"
    end
  end
end