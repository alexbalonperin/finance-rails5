# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

ROOT = Whenever.path
LOG_DIR="#{ROOT}/log"

every 1.day, :at => '9:00 pm' do
  today = Date.today
  today_str = today.to_s
  rake "populate:all", :output => {:error => "#{LOG_DIR}/populate_all/error-#{today_str}.log",
                                    :standard => "#{LOG_DIR}/populate_all/output-#{today_str}.log"}
end

every 1.week do
  command "find #{LOG_DIR}/populate_all/* -mtime +7 -exec rm {} \;", :output => {:standard => "#{LOG_DIR}/cleanup-#{Time.now}.log"}
end

# Learn more: http://github.com/javan/whenever
