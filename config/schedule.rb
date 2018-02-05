set :output, "log/cron.log"

every :day, :at => '09:00am' do
  rake "reminders:send_to_admin"
end
