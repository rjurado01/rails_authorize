require 'rails_authorize/version'

module RailsAuthorize
  # Error that will be raised when authorization has failed
  class NotAuthorizedError < StandardError; end

  ##
  # Finds policy class for given target and returns new instance
  #
  # @param target [any] the target to load policy
  # @param options [Hash] key/value options (user, policy, context)
  # @param options[:user] [Object] the user that initiated the action
  # @param options[:policy] [Class] Authorization class to use for authenticate
  # @param options[:context] [Hash] other key/value options to use in the policy methods
  #
  # @return [Object] new policy instance
  #
  def policy(target, options={})
    user = options[:user] || current_user
    klass = options[:policy] || "#{target.model_name.name}Policy".constantize

    klass.new(user, target, options[:context] || {})
  end

  ##
  # Throwing an error if the user is not authorized to perform the given action
  #
  # @param target [Object] the target we're checking permissions of
  # @param options [Hash] key/value options (action, user, policy, context)
  # @param options[:action] [String] the method to check on the policy (e.g. `:show?`)
  #
  # @raise [NotAuthorizedError] if the given action method returned false
  # @return [Object] the passed target
  #
  def authorize(target, options={})
    action = options.delete(:action) || "#{action_name}?"
    policy = policy(target, options)

    raise(NotAuthorizedError) unless policy.public_send(action)

    target
  end

  ##
  # Retrieves the policy scope for the given target
  #
  # @param target [Object] the target we're retrieving the policy scope for
  # @param options [Hash] key/value options (user, policy, context)
  #
  # @return [Scope] policy scope
  #
  def policy_scope(target, options={})
    policy(target, options).scope
  end

  ##
  # Throwing an error if the user is not authorized to perform the given action
  #
  # @param target [Object] the target we're retrieving the policy scope for
  # @param options [Hash] key/value options (action, user, policy, context)
  # @param options[:action] [String] the method to check on the policy (e.g. `:show?`)
  #
  # @raise [NotAuthorizedError] if the given action method returned false
  # @return [Scope] authorized policy scope
  #
  def authorized_scope(target, options={})
    action = options.delete(:action) || "#{action_name}?"
    policy = policy(target, options)

    raise(NotAuthorizedError) unless policy.public_send(action)

    policy.scope
  end

  # Retrieves a set of permitted attributes from the policy by instantiating
  # the policy class for the given record and calling `permitted_attributes` on
  # it, or `permitted_attributes_for_{action}` if `action` is defined. It then infers
  # what key the record should have in the params hash and retrieves the
  # permitted attributes from the params hash under that key.
  #
  # @param record [Object] the object we're retrieving permitted attributes for
  # @param options [Hash] key/value options (action, user, policy, context)
  # @param options[:action] [String] the method to check on the policy (e.g. `:show?`)
  # @return [Hash{String => Object}] the permitted attributes
  def permitted_attributes(target, options={})
    action = options.delete(:action) || action_name
    policy = policy(target, options)

    method_name = if policy.respond_to?("permitted_attributes_for_#{action}")
                    "permitted_attributes_for_#{action}"
                  else
                    'permitted_attributes'
                  end

    param_key = if policy.try(:param_key).present?
                  policy.param_key
                else
                  target.model_name.name.underscore
                end

    params.require(param_key).permit(*policy.public_send(method_name))
  end
end
