# RailsAuthorize
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
    if user.can?(:edit_status)
      %i[status body title]
    else
      %i[body title]
    end
  end
end
```
You could also define a `permitted_attributes_for_{name_action}` and it will be called instead of `permitted_attributes`.

By default `permitted_attributes` makes `params.require(:post)` if you want to personalize what attribute is required in params, your policy must define a `param_key`.

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
  end

  def update
    @post.update(permitted_attributes(@post))
  end

  def show
    @post = Post.find(params[:id])
    authorize @post
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rjurado01/rails_authorize.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
