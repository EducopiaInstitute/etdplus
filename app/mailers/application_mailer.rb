class ApplicationMailer < ActionMailer::Base
  default from: Sufia.config.from_email
  layout 'mailer'
end
