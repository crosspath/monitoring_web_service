class Spec
  attr_reader :redis, :spec_file, :domains, :options

  def initialize(file, options = {})
    @options   = {redis: true, domain: {}}.merge(options)
    @redis     = @options[:redis] && RedisInstance.connect
    @spec_file = file.sub("#{Rails.root}/", '')
    @domains   = []

    instance_eval(File.read(file))
  end

  # For DSL
  def domain(url, &block)
    key         = "results~#{@spec_file}~#{url}"
    options     = {redis_key: key}.merge(@options[:domain])
    spec_domain = Spec::Domain.new(url, @redis, options)

    @domains << {domain: spec_domain, block: block}
  end

  def run
    @domains.each do |d|
      d[:domain].instance_eval(&d[:block])
      d[:domain].save_result_and_send_mail
    end
  end

  class Domain
    attr_reader :domain, :redis, :failed_tests, :passed_tests, :response, :urls, :options

    TIMEOUT = 5
    RE_TOKEN = /<input\s+[^>]*name=[\'\"]authenticity_token[\'\"].*\/?>/
    RE_TOKEN_VALUE = /\s+value=[\'\"](?<token>.*?)[\'\"]\s*/

    def initialize(url, redis, options = {})
      @options = {send_mails: true, emulate: false}.merge(options)
      @domain  = url
      @redis   = redis

      @failed_tests ||= []
      @passed_tests ||= []
      @urls         ||= []
    end

    def cached_results
      results = @redis && @redis.get(options[:redis_key])
      results = results ? JSON.parse(results) : {}

      results['failed_tests'] ||= []
      results['passed_tests'] ||= []
      results
    end

    def cached_results=(results)
      @redis && @redis.set(options[:redis_key], results.to_json)
    end

    # Кешируем результаты тестов в Redis, чтобы не слать письма повторно
    def save_result_and_send_mail
      return if @options[:emulate]

      results     = cached_results
      new_results = {failed_tests: @failed_tests, passed_tests: @passed_tests}.deep_stringify_keys

      unless results == new_results
        self.cached_results = new_results
        if @options[:send_mails]
          emails = Rails.configuration.admins[:emails]
          UserMailer.status_mail(self, emails).deliver
        end
      end
    end

    def domain_url(url)
      p = @domain.include?(':/') ? '' : 'http://'
      "#{p}#{@domain}#{url}"
    end

    def request(url, func = nil)
      @urls << url
      return if @options[:emulate]
      score = 0
      begin
        url     = domain_url(url)
        prev    = @redis && @redis.get(url)
        options = {timeout: TIMEOUT}
        options[:cookies] = @cookie if instance_variable_defined?(:@cookie)

        begin
          @response = yield(url, options)
        rescue => e
          unless e.message.start_with?('Connection refused') || e.message.include?('Net::ReadTimeout')
            raise e
          end
          @response = yield(url, options) # ещё одна попытка
        end

        if @response.headers.key?("set-cookie")
          @cookie = [@response.headers["set-cookie"].split('=', 2)].to_h
        end
        result = func ? func.call : success?
        raise RuntimeError, "Does not satisfy conditions" unless result

        @passed_tests << {
          url:  url,
          code: @response && "#{@response.code} #{@response.message}"
        }
        @redis.set(url, '1') if prev != '1' && @redis # тест пройден успешно
      rescue => e
        score += 1
        # записать результат в память. если тест раньше проходил успешно, то отправить письмо админу
        @failed_tests << {
          url:     url,
          message: e.message,
          code:    @response && "#{@response.code} #{@response.message}"
        }
        @redis.set(url, '0') if prev != '0' && @redis
      end
      score == 0
    end

    # For DSL
    
    def visit(url, func = nil)
      request(url, func) { |url, options| HTTParty.get(url, options) }
    end

    def send_form(url, data = {}, func = nil)
      request(url, func) { |url, options| HTTParty.post(url, options.merge(body: data)) }
    end

    def success?
      @response.code.to_i < 400
    end

    def include?(text)
      @response.body.include?(text)
    end

    def match?(regexp)
      @response.body.match(regexp)
    end

    def auth(options = {})
      options.symbolize_keys!
      form_url  = options[:form_url]
      login_url = options[:login_url]
      cred      = options[:credentials]

      if visit(form_url)
        token_input_matches = @response.body.match(RE_TOKEN)
        token_value         = nil

        if token_input_matches
          value_matches = token_input_matches[0].match(RE_TOKEN_VALUE)
          token_value   = value_matches['token']

          if token_value
            send_form(login_url, cred.merge(authenticity_token: token_value))
          end
        end

        unless token_value
          raise RuntimeError, "Cannot find authenticity_token"
        end
      end

      true
    end
  end
end
