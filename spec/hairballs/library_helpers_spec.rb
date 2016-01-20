require 'spec_helper'
require 'hairballs'
require 'hairballs/library_helpers'

RSpec.describe Hairballs::LibraryHelpers do
  subject { Object.new.extend described_class }

  describe '#libraries' do
    context 'block given' do
      it 'yields an empty array' do
        expect { |b| subject.libraries(&b) }.to yield_with_args([])
      end

      it 'allows adding to the yielded array' do
        expect do
          subject.libraries do |libs|
            libs << 'meow'
          end
        end.to change { subject.instance_variable_get(:@libraries) }.
          from(nil).to(['meow'])
      end
    end

    context 'block not given' do
      it 'sets @libraries to the given param' do
        expect do
          subject.libraries(['meow'])
        end.to change { subject.instance_variable_get(:@libraries) }.
          from(nil).to(['meow'])
      end
    end

    context 'block AND param given' do
      it 'sets @libraries to the param value' do
        expect do
          subject.libraries(['meow'])
        end.to change { subject.instance_variable_get(:@libraries) }.
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
      let(:lib_name) { 'asdfqwer' }
      let(:dependency_requirer) { instance_double 'Fiber' }
      let(:dependency_installer) { instance_double 'Fiber' }

      before do
        subject.instance_variable_set(:@libraries, [lib_name])
        allow(subject).to receive(:vputs)
      end

      context 'libraries are not installed' do
        it 'tries two times to require then Gem.install' do
          expect(subject).to receive(:new_dependency_requirer).
            with(instance_of(Fiber)).and_return(dependency_requirer)
          expect(subject).to receive(:install_missing_dependencies).
            with([lib_name], dependency_requirer).
            and_return(dependency_installer)
          expect(dependency_installer).to receive(:resume)

          subject.require_libraries
        end
      end
    end
  end

  describe '#find_latest_gem' do
    it 'returns the path to the latest version of the gem' do
      expect(subject.find_latest_gem('rake')).to match %r{gems/rake}
    end
  end

  describe '#install_missing_dependencies' do
    let(:source) { instance_double 'Fiber' }
    before { expect(Fiber).to receive(:new).and_yield }

    context 'deps are empty' do
      it 'never resumes the source fiber' do
        expect(source).to_not receive(:resume)

        subject.send(:install_missing_dependencies, [], source)
      end
    end

    context 'deps are not empty' do
      it 'resumes the source fiber with the name of the dep' do
        expect(source).to receive(:resume).with('meow')

        subject.send(:install_missing_dependencies, ['meow'], source)
      end
    end
  end
end
