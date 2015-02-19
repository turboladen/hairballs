require 'spec_helper'
require 'hairballs/theme'

RSpec.describe Hairballs::Theme do
  subject(:theme) { described_class.new(:test) }

  describe '#irb_name' do
    subject { theme.irb_name }
    it { is_expected.to eq :TEST }
  end
end
