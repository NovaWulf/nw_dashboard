RSpec.describe Fetchers::GithubActivityFetcher do
  include_context 'github rest client'

  subject { described_class.run(repo: repo) }
  let(:repo) { Repo.create(token: 'btc', user: 'bob', name: 'myrepo') }

  context 'no data' do
    it 'creates commit' do
      subject
      expect(RepoCommit.count).to eql 1
      expect(RepoCommit.last.repo).to eq repo
      expect(RepoCommit.last.count).to eq 10
    end

    it 'sets last fetched at' do
      subject
      expect(repo.last_fetched_at).to be_present
    end
  end

  context 'existing data' do
    before do
      RepoCommit.create(repo: repo, day: Date.today, count: 5)
    end

    it 'should update, not create' do
      subject
      expect(RepoCommit.count).to eql 1
      expect(RepoCommit.last.count).to eq 10
    end
  end

  context 'error' do
    let(:github_double) do
      double('github client', commit_activity: { message: 'Not Found' }.with_indifferent_access)
    end

    it 'should set error' do
      subject
      expect(RepoCommit.count).to eql 0
      expect(repo.error_fetching_at).to be_present
    end
  end
end
