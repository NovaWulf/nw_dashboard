RSpec.describe RepoCreator do
  subject { described_class.run(token: 'btc', description: 'bob/john') }

  let(:canonicalizer_double) { double('canonicalizer', run: true) }

  before(:each) do
    allow_any_instance_of(described_class).to receive(:canonicalizer).and_return(canonicalizer_double)
  end

  it 'creates a repo' do
    expect { subject }.to change { Repo.count }.by(1)
    expect(Repo.first.token).to eql 'btc'
    expect(Repo.first.user).to eql 'bob'
    expect(Repo.first.name).to eql 'john'
  end

  it 'calls the canonicalizer' do
    expect(canonicalizer_double).to receive(:run)
    subject
  end

  context 'existing repo' do
    let!(:existing_repo) { Repo.create(token: 'btc', user: 'bob', name: 'john') }

    it 'does not create repo' do
      expect { subject }.not_to change { Repo.count }
    end
    it 'does not call the canonicalizer' do
      expect(canonicalizer_double).not_to receive(:run)
      subject
    end
  end
end
