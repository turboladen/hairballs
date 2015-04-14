require 'spec_helper'
require 'hairballs/plugin'

RSpec.describe Hairballs::Plugin do
  subject { described_class.new('test', one: 1, two: 2) }

  describe '#initialize' do
    context 'with attributes' do
      it 'defines getters and setters for each attribute' do
        expect(subject.one).to eq 1
        subject.one = 1.1
        expect(subject.one).to eq 1.1

        expect(subject.two).to eq 2
        subject.two = 2.2
        expect(subject.two).to eq 2.2
      end
    end
  end

  describe '#on_load' do
    let(:the_block) { proc { puts 'hi' } }

    it 'stores the given block' do
      expect do
        subject.on_load(&the_block)
      end.to change { subject.instance_variable_get(:@on_load) }.
        from(nil).to(the_block)
    end
  end

  describe '#load!' do
    context 'with attributes' do
      it 'sets the attributes' do
        expect(subject).to receive(:one=).with('thing one')
        expect(subject).to receive(:two=).with('thing two')
        allow(subject).to receive(:require_libraries)

        subject.load! one: 'thing one', two: 'thing two'
      end
    end

    context 'without attributes' do
      it 'does not set the attributes' do
        expect(subject).to_not receive(:one=)
        expect(subject).to_not receive(:two=)
        allow(subject).to receive(:require_libraries)

        subject.load!
      end
    end

    context 'with @on_load set to a Proc' do
      let(:on_load) { double 'Proc', kind_of?: true }
      before { subject.instance_variable_set(:@on_load, on_load) }

      it 'calls the on_load Proc' do
        expect(on_load).to receive(:call)
        subject.load!
      end
    end

    context 'with @on_load set to not a Proc' do
      let(:on_load) { double 'Proc', kind_of?: false }
      before { subject.instance_variable_set(:@on_load, on_load) }

      it 'raises a PluginLoadFailure' do
        expect { subject.load! }.to raise_exception Hairballs::PluginLoadFailure
      end
    end
  end
end
