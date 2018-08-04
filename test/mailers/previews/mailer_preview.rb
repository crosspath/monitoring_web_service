class MailerPreview < ActionMailer::Preview
  def status_mail
    fake_domain = Struct.new(:domain, :failed_tests, :passed_tests)
    t = {url: '%url%', message: '%message%', code: '%code%'}
    domain = fake_domain.new('%domain%', [t, t], [t, t, t])
    UserMailer.status_mail(domain, Rails.configuration.admins[:emails])
  end
end
