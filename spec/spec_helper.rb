require "simplecov"
SimpleCov.start { command_name "spec" }

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'manageiq/gems/pending'

# Initialize the global logger that might be expected
require 'logger'
$log ||= Logger.new("/dev/null")
# $log ||= Logger.new(STDOUT)
# $log.level = Logger::DEBUG

# For Appliance console logging tests
require 'tmpdir'
RAILS_ROOT = Pathname.new(Dir.mktmpdir("manageiq-gems-pending"))
Dir.mkdir(RAILS_ROOT.join("log"))

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(__dir__, 'support/**/*.rb'))].each { |f| require f }

RSpec.configure do |config|
  config.after(:each) do
    Module.clear_all_cache_with_timeout if Module.respond_to?(:clear_all_cache_with_timeout)
  end

  if ENV["CI"]
    config.after(:suite) do
      require_relative "coverage_helper"
    end
  end

  config.backtrace_exclusion_patterns -= [%r{/lib\d*/ruby/}, %r{/gems/}]
  config.backtrace_exclusion_patterns << %r{/lib\d*/ruby/[0-9]}
  config.backtrace_exclusion_patterns << %r{/gems/[0-9][^/]+/gems/}
end

VCR.configure do |c|
  c.cassette_library_dir = TestEnvHelper.recordings_dir
  c.hook_into :webmock

  c.allow_http_connections_when_no_cassette = false
  c.default_cassette_options = {
    :record                         => :once,
    :allow_unused_http_interactions => true
  }

  TestEnvHelper.vcr_filter(c)

  # c.debug_logger = File.open(Rails.root.join("log", "vcr_debug.log"), "w")
end
