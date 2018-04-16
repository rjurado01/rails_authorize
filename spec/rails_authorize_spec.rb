RSpec.describe RailsAuthorize do
  it 'has a version number' do
    expect(RailsAuthorize::VERSION).not_to be nil
  end

  subject do
    extend(described_class)
  end

  let(:post) { Post.new }
  let(:without_policy) { WithoutPolicy.new }
  let(:user) { {name: 'User'} }
  let(:current_user) { {name: 'Current user'} }
  let(:action_name) { :index }

  describe '.policy' do
    context 'when use default values' do
      it 'returns new target policy instance' do
        expect(subject.policy(post).class).to eq PostPolicy
      end

      it 'uses passed :target' do
        expect(subject.policy(post).target).to eq post
      end

      it 'uses :current_user' do
        expect(subject.policy(post).user).to eq(current_user)
      end
    end

    context 'when target has not policy' do
      it 'throws an error' do
        expect { subject.policy(without_policy).class }.to raise_error(NameError)
      end
    end

    context 'when pass :user option' do
      it 'uses this to create instance' do
        expect(subject.policy(post, user: user).user).to eq(user)
      end
    end

    context 'when pass :policy option' do
      it 'uses this to create instance' do
        expect(subject.policy({}, policy: PostPolicy).class)
          .to eq(PostPolicy)
      end
    end

    context 'when pass :context option' do
      it 'uses this to create instance' do
        context = {ip: '127.0.0.1'}
        expect(subject.policy(post, context: context).context).to eq(context)
      end
    end

    context 'when do not pass :context option' do
      it 'sets default context' do
        expect(subject.policy(post).context).to eq({})
      end
    end
  end

  describe '.authorize' do
    context 'when policy method returns true' do
      it 'returns target' do
        expect(subject.authorize(post)).to eq(post)
      end
    end

    context 'when policy method returns false' do
      let(:action_name) { :show }

      it 'throws NotAuthorizedError error' do
        expect { subject.authorize(post) }.to raise_error(RailsAuthorize::NotAuthorizedError)
      end
    end

    context 'when use default values' do
      it 'uses controller action name' do
        policy = PostPolicy.new(user, post, {})
        expect(subject).to receive(:policy).with(post, {}).and_return(policy)
        expect(policy).to receive('index?').and_return(true)
        subject.authorize(post)
      end
    end

    context 'when pass :action option' do
      it 'uses this as policy method name' do
        policy = PostPolicy.new(user, post, {})
        expect(subject).to receive(:policy).with(post, {}).and_return(policy)
        expect(policy).to receive('custom?').and_return(true)
        subject.authorize(post, action: 'custom?')
      end
    end
  end

  describe '.policy_scope' do
    it 'returns policy scope' do
      expect(subject.policy_scope(Post)).to eq([])
    end
  end

  describe '.authorized_scope' do
    context 'when policy method returns true' do
      it 'returns policy scope' do
        expect(subject.authorized_scope(Post)).to eq([])
      end
    end

    context 'when policy method returns false' do
      let(:action_name) { :show }

      it 'throws NotAuthorizedError error' do
        expect {
          subject.authorized_scope(Post)
        }.to raise_error(RailsAuthorize::NotAuthorizedError)
      end
    end

    context 'when use default values' do
      it 'uses controller action name' do
        policy = PostPolicy.new(user, Post, {})
        expect(subject).to receive(:policy).with(Post, {}).and_return(policy)
        expect(policy).to receive('index?').and_return(true)
        subject.authorized_scope(Post)
      end
    end

    context 'when pass :action option' do
      it 'uses this as policy method name' do
        policy = PostPolicy.new(user, Post, {})
        expect(subject).to receive(:policy).with(Post, {}).and_return(policy)
        expect(policy).to receive('custom?').and_return(true)
        subject.authorized_scope(Post, action: 'custom?')
      end
    end
  end
end
