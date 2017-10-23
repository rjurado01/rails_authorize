RSpec.describe RailsAuthorize do
  it 'has a version number' do
    expect(RailsAuthorize::VERSION).not_to be nil
  end

  subject do
    extend(described_class)
  end

  let(:post) { Post.new }
  let(:without_authorization) { WithoutAuthorization.new }
  let(:user) { {name: 'User'} }
  let(:current_user) { {name: 'Current user'} }

  describe '.authorization' do
    context 'when use default values' do
      it 'returns new object authorization instance' do
        expect(subject.authorization(post).class).to eq PostAuthorization
      end

      it 'uses passed :object' do
        expect(subject.authorization(post).object).to eq post
      end

      it 'uses :current_user' do
        expect(subject.authorization(post).user).to eq(current_user)
      end
    end

    context 'when object has not authorization' do
      it 'throws and error' do
        expect { subject.authorization(without_authorization).class }.to raise_error(NameError)
      end
    end

    context 'when pass :user option' do
      it 'uses this to create instance' do
        expect(subject.authorization(post, user: user).user).to eq(user)
      end
    end

    context 'when pass :authorization option' do
      it 'uses this to create instance' do
        expect(subject.authorization({}, authorization: PostAuthorization).class)
          .to eq(PostAuthorization)
      end
    end

    context 'when pass :context option' do
      it 'uses this to create instance' do
        context = {ip: '127.0.0.1'}
        expect(subject.authorization(post, context: context).context).to eq(context)
      end
    end
  end
end
