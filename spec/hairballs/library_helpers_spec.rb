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

      before do
        subject.instance_variable_set(:@libraries, [lib_name])
        allow(subject).to receive(:vputs)
      end

      context 'libraries are not installed' do
        it 'tries two times to require then Gem.install' do
          expect(subject).to receive(:start_install_thread).
            with(lib_name, instance_of(Queue))
          expect(subject).to receive(:start_require_thread).
            with(instance_of(Queue))

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

  describe '#start_install_thread' do
    before { allow(Thread).to receive(:new).and_yield }
    let(:require_queue) { instance_double 'Queue' }
    let(:lib_name) { 'some lib' }

    context 'gem exists' do
      let(:gem) { double 'Gem::Specification' }

      it 'puts the library name on the require_queue' do
        expect(Gem).to receive(:install).with(lib_name).and_return([gem])
        expect(require_queue).to receive(:<<).with(lib_name)

        subject.send(:start_install_thread, lib_name, require_queue)
      end
    end

    context 'gem does not exist' do
      it 'does not put the library name on the require_queue' do
        expect(Gem).to receive(:install).with(lib_name).and_return([])
        expect(require_queue).to_not receive(:<<)

        subject.send(:start_install_thread, lib_name, require_queue)
      end
    end
  end

  describe '#start_require_thread' do
    let(:require_queue) { instance_double 'Queue' }
    let(:lib_name) { 'test name' }
    let(:thread) { instance_double('Thread', join: nil) }
    before { allow(Thread).to receive(:new).and_yield.and_return(thread) }

    context 'rails' do
      before { expect(Hairballs.config).to receive(:rails?).and_return(true) }

      it 'finds the latest gem and adds it to the load path' do
        lib_path = 'path to lib'
        expect(require_queue).to receive(:pop).and_return(lib_name)
        expect(subject).to receive(:find_latest_gem).with(lib_name).
          and_return(lib_path)
        expect($LOAD_PATH).to receive(:unshift).with('path to lib/lib')
        expect(subject).to receive(:require).with(lib_name)

        subject.send(:start_require_thread, require_queue)
      end
    end

    context 'not rails' do
      before { expect(Hairballs.config).to receive(:rails?).and_return(false) }

      it 'does not find the latest gem and add it to the load path' do
        expect(require_queue).to receive(:pop).and_return(lib_name)
        expect(subject).to_not receive(:find_latest_gem)
        expect($LOAD_PATH).to_not receive(:unshift)
        expect(subject).to receive(:require).with(lib_name)

        subject.send(:start_require_thread, require_queue)
      end
    end
  end
end
