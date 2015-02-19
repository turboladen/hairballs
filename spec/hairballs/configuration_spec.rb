require 'spec_helper'
require 'hairballs/configuration'

RSpec.describe Hairballs::Configuration do
  subject(:config) { described_class.new }

  describe '#themes' do
    subject { config.themes }
    it { is_expected.to be_an Array }
    it { is_expected.to be_empty }
  end

  describe '#add_theme' do
    let(:theme) { double 'Hairballs::Theme' }

    context 'block given and name param is a Symbol' do
      before do
        expect(Hairballs::Theme).to receive(:new).with(:test).and_return theme
      end

      it 'yields the Theme' do
        expect { |b| subject.add_theme(:test, &b) }.to yield_with_args(theme)
      end

      it 'adds the Theme to @themes' do
        expect(subject.themes).to receive(:<<).with(theme)
        subject.add_theme(:test) { |_| }
      end

      it 'returns the Theme' do
        expect(subject.add_theme(:test) { |_| }).to eq theme
      end
    end

    context 'no block given' do
      before do
        allow(Hairballs::Theme).to receive(:new).and_return theme
      end

      it 'raises a LocalJumpError' do
        expect { subject.add_theme(:test) }.to raise_exception(LocalJumpError)
      end
    end
  end

  describe '#use_theme' do
    let(:theme) { double 'Hairballs::Theme', name: :test }

    context 'theme_name represents an added theme' do
      before do
        expect(subject.themes).to receive(:find).and_return theme
      end

      it 'does not raise a ThemeUseFailure' do
        allow(theme).to receive(:use!)
        expect { subject.use_theme(:test) }.to_not raise_exception
      end

      it 'tells the theme to #use!' do
        expect(theme).to receive(:use!)

        subject.use_theme(:test)
      end

      it 'sets @current_theme to the new theme' do
        allow(theme).to receive(:use!)

        expect { subject.use_theme(:test) }.
          to change { subject.instance_variable_get(:@current_theme) }.
          to(theme)
      end
    end

    context 'theme_name does not represent an added theme' do
      it 'raises a ThemeUseFailure' do
        expect(subject.themes).to receive(:find).and_return nil

        expect do
          subject.use_theme(:meow)
        end.to raise_exception(Hairballs::ThemeUseFailure)
      end
    end
  end

  describe '#plugins' do
    subject { config.plugins }
    it { is_expected.to be_an Array }
  end

  describe '#loaded_plugins' do
    subject { config.loaded_plugins }
    it { is_expected.to be_an Array }
  end

  describe '#add_plugin' do
    let(:plugin) { double 'Hairballs::Plugin' }

    context 'block given and name param is a Symbol' do
      before do
        expect(Hairballs::Plugin).to receive(:new).with(:test, {}).and_return plugin
      end

      it 'yields the Plugin' do
        expect { |b| subject.add_plugin(:test, &b) }.to yield_with_args(plugin)
      end

      it 'adds the Plugin to @plugins' do
        expect(subject.plugins).to receive(:<<).with(plugin)
        subject.add_plugin(:test) { |_| }
      end

      it 'returns the Plugin' do
        expect(subject.add_plugin(:test) { |_| }).to eq plugin
      end
    end

    context 'no block given' do
      before do
        allow(Hairballs::Plugin).to receive(:new).and_return plugin
      end

      it 'raises a LocalJumpError' do
        expect { subject.add_plugin(:test) }.to raise_exception(LocalJumpError)
      end
    end
  end

  describe '#load_plugin' do
    let(:plugin) { double 'Hairballs::Plugin', name: :test }

    context 'theme_name represents an added plugin' do
      before do
        expect(subject.plugins).to receive(:find).and_return plugin
      end

      it 'does not raise an exception' do
        allow(plugin).to receive(:load!)

        expect do
          subject.load_plugin(:test)
        end.to_not raise_exception
      end

      it 'tells the plugin to #load!' do
        expect(plugin).to receive(:load!)
        subject.load_plugin(:test)
      end

      it 'updates @loaded_plugins with the new theme' do
        allow(plugin).to receive(:load!)

        expect { subject.load_plugin(:test) }.
          to change { subject.loaded_plugins.size }.
          by(1)
      end
    end

    context 'plugin_name does not represent an added plugin' do
      it 'raises a PluginNotFound' do
        expect do
          subject.load_plugin(:meow)
        end.to raise_exception(Hairballs::PluginNotFound)
      end
    end
  end

  describe '.project_name' do
    subject { config.project_name }
    it { is_expected.to eq 'hairballs' }
  end

  describe '.project_root' do
    before do
      allow(Dir).to receive(:pwd).and_return '/meow/hairballs'
    end

    subject { config.project_name }
  end

  describe '.rails?' do
    subject { config.rails? }

    context 'not using Rails' do
      it { is_expected.to eq false }
    end

    context 'using Rails' do
      context 'RAILS_ENV is defined' do
        before { ENV['RAILS_ENV'] = 'blargh' }
        after { ENV.delete('RAILS_ENV') }
        it { is_expected.to eq true }
      end
    end
  end
end
