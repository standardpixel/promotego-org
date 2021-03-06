# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  config.include FixtureReplacement
  config.include AuthenticatedTestHelper

end

def mock_and_find(clazz, options={})
  retval = mock_model(clazz, options)
  clazz.stub!(:find).with(retval.id.to_s).and_return(retval)
  return retval
end

class MatchHash
  def initialize(expected)
    @expected = expected
  end

  def matches?(target)
    @target = target
    failure_start = "expected #{@expected.inspect}, but "

    case target
    when nil
      @failure_message = failure_start + "target is nil"
      return false
    when Hash
      target_keys = target.keys.to_a
      expected_keys = @expected.keys.to_a

      if ((missing = expected_keys - target_keys).size > 0)
        @failure_message = failure_start + "target is missing keys " +
          missing.join(", ")
        return false
      elsif ((extra = target_keys - expected_keys).size > 0)
        @failure_message = failure_start + "target has extra keys " +
          extra.inject(""){|string, key| string + "#{key.to_s}=#{target[key]} "}
        return false
      else
        mismatched_keys = []

        expected_keys.each do |key|
          if(@expected[key] != @target[key])
            mismatched_keys << key
          end
        end

        if (mismatched_keys.size > 0)
          @failure_message = failure_start + "these keys do not match in #{@target.inspect}: " +
            mismatched_keys.join(", ")
          return false
        else
          return true
        end
      end
    else
      @failure_message = failure_start + "target is not a Hash"
      return false
    end
  end

  def failure_message
    @failure_message
  end

  def negative_failure_message
    "expected #{@target.inspect} not to match hash #{@expected}"
  end
end

def match_hash(expected)
  MatchHash.new(expected)
end
