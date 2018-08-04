class ResultsRepo
  class << self
    def all
      results_by_spec = raw_grouped_by_spec
      specs = Rails.configuration.specs
      
      specs.map do |spec_name, spec_title|
        result = Result.new(name: spec_title)
        if results_by_spec[spec_name]
          results_by_spec[spec_name].each do |row|
            result.add(row)
          end
        end
        result
      end
    end
    
    def raw_grouped_by_spec
      redis = RedisInstance.connect
      
      # key: results~spec_file~url
      results = redis.keys('results~*').sort
      results_by_spec = {} # {spec_file: [{'failed_tests', 'passed_tests'}, ...], ...}
      
      results.each do |x|
        begin
          spec_file = x.match(%r{[~/]([^/]*?)\.rb})[1]
          value = JSON.parse(redis.get(x))
          results_by_spec[spec_file] ||= []
          results_by_spec[spec_file] << value
        rescue JSON::ParserError
          nil
        end
      end
      
      results_by_spec
    end
  end
end
