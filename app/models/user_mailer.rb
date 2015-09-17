class UserMailer < ActionMailer::Base

  def response_for_information(email, first_name)
    @view_data = {email:email, first_name:first_name}

    mail( to: email, bcc:, from: 'bjustice@uvic.ca', subject: "UVic Sufia - We're here to help")
  end
end