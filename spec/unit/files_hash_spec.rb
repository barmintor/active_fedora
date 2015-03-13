require 'spec_helper'

describe ActiveFedora::FilesHash do
  before do
    class Container; end
    allow(Container).to receive(:child_resource_reflections).and_return(file: reflection)
    allow(container).to receive(:association).with(:file).and_return(association)
    allow(container).to receive(:undeclared_files).and_return([])
  end

  after { undefine(:Container) }

  let(:reflection) { double('reflection') }
  let(:association) { double('association', reader: object) }
  let(:object) { double('object') }
  let(:container) { Container.new }

  subject { ActiveFedora::FilesHash.new(container) }

  describe "#key?" do
    context 'when the key is present' do
      it "should be true" do
        expect(subject.key?(:file)).to be true
      end
      it "should return true if a string is passed" do
        expect(subject.key?('file')).to be true
      end
    end

    context 'when the key is not present' do
      it "should be false" do
        expect(subject.key?(:foo)).to be false
      end
    end
  end

  describe "#[]" do
    context 'when the key is present' do
      it "should return the object" do
        expect(subject[:file]).to eq object
      end
      it "should return the object if a string is passed" do
        expect(subject['file']).to eq object
      end
    end

    context 'when the key is not present' do
      it "should be nil" do
        expect(subject[:foo]).to be_nil
      end
    end
  end
end
