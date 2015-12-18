class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@localhost"
  layout 'mailer'
end
