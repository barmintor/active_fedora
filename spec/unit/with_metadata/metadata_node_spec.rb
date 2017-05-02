require 'spec_helper'

describe ActiveFedora::WithMetadata::MetadataNode do
  let(:generated_schema) { Class.new(described_class) }

  let(:file) { ActiveFedora::File.new }
  let(:node) { generated_schema.new(file) }
  let(:book) { RDF::URI.new('http://example.com/ns/Book') }

  describe "#changed_attributes" do
    subject { node.changed_attributes }

    context "when type is not set" do
      it { is_expected.to eq({}) }
    end

    context "when type is set" do
      before do
        generated_schema.configure type: book
      end

      it { is_expected.to eq('type' => true) }
    end
  end

  describe "changes_for_update" do
    subject { changes_for_update }
    let(:changes_for_update) { node.send(:changes_for_update) }

    context "when type is not set" do
      it { is_expected.to eq({}) }
    end

    context "when type is set" do
      before do
        generated_schema.configure type: book
      end

      it "is expected to have the rdf type statement" do
        expect(changes_for_update[::RDF.type]).to be_present
      end
    end
  end

  describe ".new" do
    it "does not make a request when parent file is new" do
      expect(file.ldp_source.client).not_to receive(:head)
      described_class.new(file)
    end
  end
end
