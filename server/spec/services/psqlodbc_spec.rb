RSpec.describe RAdapter do
  subject(:instance) { described_class.new }

  it 'rodbc connects' do
    subject
    expect(instance.test_odbc).to be > 0
  end
end
