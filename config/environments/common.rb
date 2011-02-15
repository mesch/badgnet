# Define a common OPTIONS hash unless already defined
OPTIONS = {} unless defined?(OPTIONS)

OPTIONS[:default_badge_image] = "/images/default_badge.jpg"
OPTIONS[:default_action_image] = "/images/default_action.jpg"

# Admin basic auth login
OPTIONS[:admin_user_name] = "badgnet_admin"
OPTIONS[:admin_password] = "fr33d0m"

# Captcha stuff
OPTIONS[:recaptcha_public_key] = "6LeYRcESAAAAAFPjUd1v_l63xmIgVCfNqEmsACtb"
OPTIONS[:recaptcha_private_key] = "6LeYRcESAAAAAEFIJkdDt9zoNmPZw5eoTKkSYB7b"

# Params for sending emails. See config/initializers/mail.rb
# Default is to use postfix. Dev mode uses gmail. Test mode doesn't send mail

# Use the same from address and return-path for all emails
OPTIONS[:email_from] = "Badgnet Admin <admin@badg.net>"
OPTIONS[:email_return_path] = "admin@badg.net"

# Internal email info
OPTIONS[:internal_email_to] = "admin@badg.net"
OPTIONS[:internal_error_to] = "errors@badg.net"
OPTIONS[:internal_email_from] = "internal@badg.net"

# Email settings for prod and staging
OPTIONS[:action_mailer_deliver_method] = :smtp
OPTIONS[:email_address] = "smtp.sendgrid.net" 
OPTIONS[:email_port] = "25"
OPTIONS[:email_authentication] = :plain
OPTIONS[:email_username] = ENV['SENDGRID_USERNAME']
OPTIONS[:email_password] = ENV['SENDGRID_PASSWORD']
OPTIONS[:email_domain] = ENV['SENDGRID_PASSWORD']
OPTIONS[:enable_starttls_auto] = false
