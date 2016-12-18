class PagesController < ApplicationController
  def heartbeat
    @redis = Redis.new(url: REDIS[:url], namespace: REDIS[:namespace])
    results = @redis.keys('results~*').sort.map { |x| [x, @redis.get(x)] }
    @specs = {}

    results.map do |x, t|
      key = x.match(%r{[~/]([^/]*?)\.rb})[1]
      percent(key, t)
    end

    names({
              'root_domain_spec' => 'Портал',
              # Define your specs there!
          })

    @news = load_news[0..2]
  end

  protected

  def percent(key, t)
    @specs[key] ||= {}
    d = @specs[key]
    t = JSON.parse(t)
    d['failed_tests'] ||= 0
    d['failed_tests'] += t["failed_tests"].size
    d['passed_tests'] ||= 0
    d['passed_tests'] += t["passed_tests"].size
    d['%'] = 100 * d["passed_tests"] / (d["failed_tests"] + d["passed_tests"])
  end

  def names(n)
    n.each do |spec, name|
      @specs[spec] ||= {}
      @specs[spec]['name'] = name
    end
  end
end
