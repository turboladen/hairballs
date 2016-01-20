require 'spec_helper'
require 'hairballs/theme'

RSpec.describe Hairballs::Theme do
  let(:prompt) { instance_double 'Hairballs::Prompt' }
  subject(:theme) { described_class.new(:test) }
  before { allow(Hairballs::Prompt).to receive(:new).and_return(prompt) }

  describe '#irb_name' do
    subject { theme.irb_name }
    it { is_expected.to eq :TEST }
  end
end
