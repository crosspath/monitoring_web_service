class Result
  include ActiveModel::Model
  attr_accessor :name, :failed_tests, :passed_tests
  
  def percent
    failed_count = (@failed_tests || []).size
    passed_count = (@passed_tests || []).size
    
    sum = failed_count + passed_count
    sum == 0 ? nil : (100 * passed_count / sum)
  end
  
  def add(attrs = {})
    attrs.symbolize_keys!
    
    @failed_tests = [] unless @failed_tests.respond_to?('+=')
    @passed_tests = [] unless @passed_tests.respond_to?('+=')
    
    @failed_tests += attrs[:failed_tests] || []
    @passed_tests += attrs[:passed_tests] || []
  end
end
