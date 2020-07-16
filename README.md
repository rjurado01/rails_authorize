# RailsAuthorize
[![Gem Version](https://badge.fury.io/rb/rails_authorize.svg)](https://badge.fury.io/rb/rails_authorize)
![Build Status](https://travis-ci.org/rjurado01/rails_authorize.svg?branch=master)

Simple and flexible authorization Rails system inspired by Pundit.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails_authorize'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails_authorize

## Example

```ruby
# app/models/post.rb

class Post
  def published?
    return published == true
  end
end
```

```ruby
# app/policies/application_policy.rb

class ApplicationPolicy
  attr_reader :user, :target, :context

  def initialize(user, target, context)
    @user = user
    @target = target
    @context = context
  end
end
```

```ruby
# app/policies/post_policy.rb

class PostPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.is_admin? and target.published?
  end

  def scope
    target.where(published: true)
  end

  def permitted_attributes
    if user.admin?
      %i[status body title]
    else
      %i[body title]
    end
  end
end
```

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  include RailsAuthorize
end
```

```ruby
# app/controllers/posts_controller.rb

class PostController
  def index
    @posts = authorized_scope(Post)
    ...
  end

  def update
    @post = Post.find(params[:id])
    @post.update(permitted_attributes(@post))
    ...
  end

  def show
    @post = Post.find(params[:id])
    authorize @post
    ...
  end
end
```

## Customize user

Rails Authorize will call the `current_user` method to retrieve the user for authorization. If you need to customize it you can pass `user` as option to method `authorize`:

```ruby
# app/controllers/posts_controller.rb

class PostController
  def show
    @post = Post.find(params[:id])
    @user = User.find(params[:user_id])
    authorize @post, user: @user
    ...
  end
end
```

## Customize action

Rails Authorize will use the controller action name as identifier of policy method to use for authorization. If you need to customize it you can pass `action` as option to method `authorize`:

```ruby
# app/controllers/posts_controller.rb

class PostController
  def show
    @post = Post.find(params[:id])
    authorize @post, action: :custom_action?
    ...
  end
end
```

## Define context

Rails Authorize allow you to define the context objects that you need to authorize an action:

```ruby
# app/controllers/posts_controller.rb

class PostController
  def show
    @post = Post.find(params[:id])
    authorize @post, context: {template: params[:template]}
    ...
  end
end
```

```ruby
# app/policies/post_policy.rb

class PostPolicy < ApplicationPolicy
  def show?
    if context[:template] == 'complete' ?
      user.is_admin?
    else
      true
    end
  end
end
```

## Strong parameters

Rails uses [strong_parameters](http://edgeguides.rubyonrails.org/action_controller_overview.html#strong-parameters) to handle mass-assignment protection in the controller.  With this gem you can control which attributes a user has access via your policies.

You can set up a `permitted_attributes` method in your policy like this:

```ruby
# app/policies/post_policy.rb

class PostPolicy < ApplicationPolicy
  def permitted_attributes
    if user.admin?
      %i[status body title]
    else
      %i[body title]
    end
  end
end
```

You can now retrieve these attributes from the policy:

```ruby
policy(@post).permitted_attributes
policy(Post).permitted_attributes
```

Rails Authorize provides `permitted_attributes` helper method to use it in your controllers:

```ruby
# app/controllers/posts_controller.rb

class PostController
  def create
    Post.create(permitted_attributes(Post))
  end
  
  def update
    @post.update(permitted_attributes(@post))
  end
end
```

By default `permitted_attributes` makes `params.require(:post)` if you want to personalize what attribute is required in params, your policy must define a `param_key`:

```ruby
# app/policies/post_policy.rb

class PostPolicy < ApplicationPolicy
  def param_key
    'custom_key'
  end
end
```

Also, you can pass custom key as option using `param_key` for specific situations:

```ruby
# app/controllers/posts_controller.rb

class PostController
  def update
    @post.update(permitted_attributes(@post, param_key: 'custom_key'))
  end
end
```

If you want to permit different attributes based on the current action, you can define a `permitted_attributes_for_#{action_name}` method on your policy:

```ruby
# app/policies/post_policy.rb

class PostPolicy < ApplicationPolicy
  def permitted_attributes_for_create
    [:title, :body]
  end

  def permitted_attributes_for_update
    [:body]
  end
end
```

## Use without target

Sometimes you need to authorize a controller action that it doesn't use a model to authorize.

For this situations you can omit `target` and pass only options with `policy` to `authorize` or `permitted_attributes`:

```ruby
# app/controllers/custom_controller.rb

class CustomController
  def show
    authorize policy: CustomPolicy
    ...
  end

  def create
    resource = Resource.new(permitted_attributes(policy: CustomPolicy))
    ...
  end
end
```

```ruby
# app/policies/custom_policy.rb

class CustomPolicy < ApplicationPolicy
  def show?
    # target is nil
    ...
  end

  def permitted_attributes
    [:title, :body]
  end
end
```



## Ensuring authorization and scoping are performed

In certain kind of applications where almost all or even the whole application is private, in each of the actions you have to make sure that authorization is performed. To make sure that developers perform authorization, RailsAuthorize provides two methods. `verify_authorized` makes sure that authorization is performed, and likewise `verify_policy_scoped` checks that scoping is performed 

Both methods are mainly aimed to be called on `after_action`.
```ruby
class ApplicationController < ActionController::Base
  include RailsAuthorize
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index
end
```

### Skipping verification

If you're using `verify_authorized` in your controllers but need to conditionally bypass verification, you can use `skip_authorization`. For bypassing `verify_policy_scoped`, use `skip_policy_scope`.
```ruby
def create
  record = Record.new(attributes)

  if record.valid?
    authorize record
  else
    skip_authorization
  end
end
```

## Rspec

For writing expressive tests for your policies in RSpec you can use this gem: [rails_authorize_matchers](https://github.com/pacop/rails_authorize_matchers)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rjurado01/rails_authorize.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
