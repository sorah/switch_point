require 'coveralls'
require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter,
]
SimpleCov.start do
  add_filter Bundler.bundle_path.to_s
  add_filter File.dirname(__FILE__)
end

require 'switch_point'
require 'models'

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  if config.files_to_run.one?
    config.full_backtrace = true
    config.default_formatter = 'doc'
  end

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    Book.with_writable do
      Book.connection.execute('CREATE TABLE books (id integer primary key autoincrement)')
    end
    FileUtils.cp('main_writable.sqlite3', 'main_readonly.sqlite3')

    Note.connection.execute('CREATE TABLE notes (id integer primary key autoincrement)')
  end

  config.after(:suite) do
    ActiveRecord::Base.configurations.each_value do |config|
      FileUtils.rm_f(config[:database])
    end
  end

  config.after(:each) do
    Book.with_writable do
      Book.delete_all
    end
    FileUtils.cp('main_writable.sqlite3', 'main_readonly.sqlite3')
  end
end

RSpec::Matchers.define :connect_to do |expected|
  database_name = lambda do |model|
    model.connection.pool.spec.config[:database]
  end

  match do |actual|
    database_name.call(actual) == expected
  end

  failure_message do |actual|
    "expected #{actual.name} to connect to #{expected} but connected to #{database_name.call(actual)}"
  end
end
