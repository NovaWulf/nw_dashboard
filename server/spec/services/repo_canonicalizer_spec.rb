RSpec.describe RepoCanonicalizer do
  include_context 'github rest client'

  subject { described_class.run(repo: repo) }
  let(:repo) { Repo.create(token: 'btc', user: 'bob', name: 'john') }

  let(:creator_double) { double('creator', run: true) }

  before(:each) do
    allow_any_instance_of(described_class).to receive(:repo_creator).and_return(creator_double)
  end

  context 'missing repo' do
    let(:github_double) do
      double('github client', repo_details: { message: 'Not Found' }.with_indifferent_access)
    end

    it 'sets error' do
      subject
      expect(repo.error_fetching_at).to be_present
      expect(repo.canonical).to eql false
      expect(repo.github_id).to be_nil
    end
  end

  context 'canonical repo' do
    it 'sets metadata' do
      subject
      expect(repo.github_id).to be_present
      expect(repo.canonical).to be_truthy
    end

    it 'does not call creator' do
      expect(creator_double).not_to receive(:run)
      subject
    end
  end

  context 'non-canonical repo' do
    let(:repo) { Repo.create(token: 'btc', user: 'bob', name: 'johnny') }
    it 'sets metadata' do
      subject
      expect(repo.github_id).to be_present
      expect(repo.canonical).to be_falsy
    end

    it 'calls creator' do
      expect(creator_double).to receive(:run)
      subject
    end
  end
end
