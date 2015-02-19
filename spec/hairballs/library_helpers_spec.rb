require 'spec_helper'
require 'hairballs/library_helpers'

RSpec.describe Hairballs::LibraryHelpers do
  subject { Object.new.extend described_class }

  describe '#libraries' do
    context 'block given' do
      it 'yields an empty array' do
        expect { |b| subject.libraries(&b) }.to yield_with_args([])
      end

      it 'allows adding to the yielded array' do
        expect {
          subject.libraries do |libs|
            libs << 'meow'
          end
        }.to change { subject.instance_variable_get(:@libraries) }.
        from(nil).to(['meow'])
      end
    end

    context 'block not given' do
      it 'sets @libraries to the given param' do
        expect {
          subject.libraries(['meow'])
        }.to change { subject.instance_variable_get(:@libraries) }.
        from(nil).to(['meow'])
      end
    end

    context 'block AND param given' do
      it 'sets @libraries to the param value' do
        expect {
          subject.libraries(['meow'])
        }.to change { subject.instance_variable_get(:@libraries) }.
        from(nil).to(['meow'])
      end
    end
  end

  describe '#require_libraries' do
    context '@libraries is nil' do
      it 'returns nil' do
        expect(subject.require_libraries).to be_nil
      end
    end

    context '@libraries is not nil' do
      before do
        subject.instance_variable_set(:@libraries, %w(one))
        allow(subject).to receive(:vputs)
        Hairballs.define_singleton_method(:rails?) { nil }
      end

      context 'libraries are not installed' do
        it 'tries two times to require then Gem.install' do
          expect(subject).to receive(:require).with('one').exactly(2).times.and_raise LoadError
          expect(Gem).to receive(:install).with('one').exactly(1).times

          expect { subject.require_libraries }.to raise_exception LoadError
        end
      end
    end
  end

  describe '#find_latest_gem' do
    it 'returns the path to the latest version of the gem' do
      expect(subject.find_latest_gem('rake')).to match %r{gems/rake}
    end
  end
end
