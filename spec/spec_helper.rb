require 'bundler/setup'
require 'rails_authorize'
require 'active_support/all'
require 'action_controller'

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

class WithoutPolicy < Model
end

class Post < Model
end

class ApplicationPolicy
  attr_reader :user, :target, :context

  def initialize(user, target, context)
    @user = user
    @target = target
    @context = context
  end
end

class PostPolicy < ApplicationPolicy
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
