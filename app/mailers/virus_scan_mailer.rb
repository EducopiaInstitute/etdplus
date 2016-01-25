class VirusScanMailer < ApplicationMailer
  default subject: 'Virus detected in upload to ETDPlus'

  def destroy_file(depositor, file_name)
    @file_name = file_name
    if depositor && @user = User.find_by_user_key(depositor)
      mail(to: @user.email)
    else
      Rails.logger.error 'Can not find depositor to send file virus message'
    end
  end

  def embargo_file(depositor, file_name)
    @file_name = file_name
    if depositor && @user = User.find_by_user_key(depositor)
      mail(to: @user.email)
    else
      Rails.logger.error 'Can not find depositor to send file virus message'
    end
  end
end
