class PiiMailer < ApplicationMailer
  default subject: 'PII detected in upload to ETDPlus'

  def destroy_file(generic_file_id)
    generic_file = GenericFile.find(generic_file_id)
    @file_name = generic_file.filename
    @url = 'https://url.edu'
    depositor = generic_file.depositor
    @user = User.find_by_user_key(depositor)
    if @user
      mail(to: @user.email)
    else
      Rails.logger.error 'Can not find depositor to send PII inspection message'
    end
  end  
end
