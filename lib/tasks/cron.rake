desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  # Daily Summarization
  Client.summarize_active_clients
end