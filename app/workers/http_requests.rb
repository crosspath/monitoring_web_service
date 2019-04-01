# По сути, выполняет то же, что и тесты RSpec - запросы определённых страниц и поиск определённого текста на них.
# Запускать надо по крону, например rails r 'HttpRequests.new.perform'.
# Желательно перенаправить stdout в лог-файл. Пример: rails r 'HttpRequests.new.perform' &> log/status.log
class HttpRequests
  include Sidekiq::Worker
  sidekiq_options retry: 2

  def perform(options = {})
    files = Dir[Rails.root.join('specs', '*.rb')]
    files.each do |file|
      begin
        spec = Spec.new(file, options)
        spec.run
      rescue => e
        puts "!!! #{File.basename(file)} #{e.message}"
        puts e.backtrace
      end
    end
  end
end
