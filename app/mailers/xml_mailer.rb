class XmlMailer < ApplicationMailer
  default subject: 'Bad-formed XML detected in upload to ETDPlus'

  def warn_file(depositor, file_name, error_msg)
    @file_name = file_name
    @parsing_errors = error_msg
    if depositor && @user = User.find_by_user_key(depositor)
      mail(to: @user.email)
    else
      Rails.logger.error 'Can not find depositor to send XML Validation message'
    end
  end

end
