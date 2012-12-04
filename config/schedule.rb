# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

# you must load this into your crontab via "whenever --update-crontab" to get this code to run

every 5.minutes do
  runner "Stream.update_live_state"
end