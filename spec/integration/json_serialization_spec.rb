require 'spec_helper'

describe "Objects should be serialized to JSON" do
  it "should have json results" do
    expect(ActiveFedora::Base.new.to_json).to eq "{\"id\":null}"
  end

  context "with properties and datastream attributes" do
    before do
      class Foo < ActiveFedora::Base
        has_metadata 'descMetadata', type: ActiveFedora::SimpleDatastream do |m|
          m.field "foo", :text
          m.field "bar", :text
        end
        has_attributes :foo, datastream: 'descMetadata', multiple: true
        has_attributes :bar, datastream: 'descMetadata', multiple: false
        property :title, predicate: ::RDF::DC.title
      end
    end

    after do
      undefine(:Foo)
    end

    let(:obj) { Foo.new(foo: ["baz"], bar: 'quix', title: ['My Title']) }

    before { allow(obj).to receive(:id).and_return('test-123') }

    subject { JSON.parse(obj.to_json)}

    it "should have to_json" do
      expect(subject['id']).to eq "test-123"
      expect(subject['foo']).to eq ["baz"]
      expect(subject['bar']).to eq "quix"
      expect(subject['title']).to eq ["My Title"]
    end
  end

  context "with nested nodes" do
    before do
      class DummySubnode < ActiveTriples::Resource
        property :relation, predicate: ::RDF::DC[:relation]
      end

      class DummyResource < ActiveFedora::RDFDatastream
        property :license, predicate: ::RDF::DC[:license], class_name: DummySubnode do |index|
          index.as :searchable, :displayable
        end
        def serialization_format
          :ntriples
        end
      end

      class DummyAsset < ActiveFedora::Base
        has_metadata  'descMetadata', type: DummyResource
        has_attributes :relation, datastream: 'descMetadata', at: [:license, :relation], multiple: false
      end
    end

    after do
      undefine("DummyAsset")
      undefine("DummyResource")
      undefine("DummySubnode")
    end

    let(:obj) { DummyAsset.new { |a| a.relation = 'Great Grandchild' } }
    before { allow(obj).to receive(:id).and_return('test-123') }

    subject { JSON.parse(obj.to_json)}

    it { should eq("id"=>"test-123", "relation"=>"Great Grandchild") }
  end
end
