require 'bundler/setup'
require 'rails_authorize'
require 'active_support/all'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

class Model
  def self.model_name
    OpenStruct.new(name: to_s)
  end

  def model_name
    self.class.model_name
  end
end

class WithoutAuthorization < Model
end

class Post < Model
end

class ApplicationAuthorization
  attr_reader :user, :object, :context

  def initialize(user, object, context)
    @user = user
    @object = object
    @context = context
  end
end

class PostAuthorization < ApplicationAuthorization
  def index?
    true
  end

  def show?
    false
  end

  def scope
    []
  end
end
