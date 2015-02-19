require 'spec_helper'
require 'hairballs'

describe Hairballs do
  subject(:hairballs) { described_class }

  describe '.config' do
    subject { hairballs.config }
    it { is_expected.to be_a Hairballs::Configuration }
  end

  it { is_expected.to respond_to(:themes) }
  it { is_expected.to respond_to(:current_theme) }
  it { is_expected.to respond_to(:add_theme) }
  it { is_expected.to respond_to(:use_theme) }

  it { is_expected.to respond_to(:plugins) }
  it { is_expected.to respond_to(:loaded_plugins) }
  it { is_expected.to respond_to(:add_plugin) }
  it { is_expected.to respond_to(:load_plugin) }

  it { is_expected.to respond_to(:completion_procs) }

  it { is_expected.to respond_to(:project_name) }
  it { is_expected.to respond_to(:project_root) }
  it { is_expected.to respond_to(:rails?) }

  it { is_expected.to respond_to(:version) }
end
