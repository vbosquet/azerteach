set :output, "log/cron.log"

every :day, :at => '03:00am' do
  rake "reminders:send_to_admin"
end

