# coding: utf-8
class UserMailer < ActionMailer::Base
  layout 'mailer'

  # http://localhost:5000/rails/mailers/mailer/status_mail
  def status_mail(domain, to)
    @failed_tests = domain.failed_tests || []
    @passed_tests = domain.passed_tests || []
    @domain = domain.domain
    
    @title = "Результаты прохождения тестов по домену <a href='http://#{@domain}'>#{@domain}</a>".html_safe
    
    mail(to: to, subject: domain.domain)
  end
end
