require 'rails_authorize/version'

module RailsAuthorize
  # Error that will be raised when authorization has failed
  class NotAuthorizedError < StandardError; end

  ##
  # Finds authorization class for given object and returns new instance
  #
  # @param object [any] the object to load authorization
  # @param options [Hash] key/value options (user, authorization, context)
  # @param options[:user] [Object] the user that initiated the action
  # @param options[:authorization] [Class] Authorization class to use for authenticate
  # @param options[:context] [Hash] other key/value options to use in the authorization methods
  #
  # @return [Object] new authorization instance
  #
  def authorization(object, options={})
    user = options[:user] || current_user
    klass = options[:authorization] || "#{object.model_name.name}Authorization".constantize

    klass.new(user, object, options[:context])
  end

  ##
  # Throwing an error if the user is not authorized to perform the given action
  #
  # @param object [Object] the object we're checking permissions of
  # @param options [Hash] key/value options (action, user, authorization, context)
  # @param options[:action] [String] the method to check on the authorization (e.g. `:show?`)
  #
  # @raise [NotAuthorizedError] if the given action method returned false
  # @return [Object] the passed object
  #
  def authorize(object, options={})
    action = options[:action] || "#{action_name}?"
    authorization = authorization(scope, options)

    raise(NotAuthorizedError) unless authorization.public_send(action)

    object
  end

  ##
  # Throwing an error if the user is not authorized to perform the given action
  #
  # @param object [Object] the object we're retrieving the policy scope for
  # @param options [Hash] key/value options (action, user, authorization, context)
  # @param options[:action] [String] the method to check on the authorization (e.g. `:show?`)
  #
  # @raise [NotAuthorizedError] if the given action method returned false
  # @return [Scope] authorization scope
  #
  def authorized_scope(object, options={})
    action = options[:action] || "#{action_name}?"
    authorization = authorization(object, options)

    raise(NotAuthorizedError) unless authorization.public_send(action)

    authorization.scope
  end

  ##
  # Retrieves the authorization scope for the given object
  #
  # @param object [Object] the object we're retrieving the policy scope for
  # @param options [Hash] key/value options (user, authorization, context)
  #
  # @return [Scope] authorized scope
  #
  def authorization_scope(object, options={})
    authorization(object, options).scope
  end
end
