# -*- encoding: utf-8 -*-
require 'spec_helper'

describe ActiveFedora::RDFDatastream do
  describe "a new instance" do
    its(:metadata?) { should be_true}
    its(:content_changed?) { should be_false}
  end
  describe "an instance that exists in the datastore, but hasn't been loaded" do
    before do
      class MyDatastream < ActiveFedora::NtriplesRDFDatastream
        property :title, :predicate => RDF::DC.title
        property :description, :predicate => RDF::DC.description, :multivalue => false
      end
      class MyObj < ActiveFedora::Base
        has_metadata 'descMetadata', type: MyDatastream
      end
      @obj = MyObj.new
      @obj.descMetadata.title = 'Foobar'
      @obj.save
    end
    after do
      @obj.destroy
      Object.send(:remove_const, :MyDatastream)
      Object.send(:remove_const, :MyObj)
    end
    subject { @obj.reload.descMetadata }
    it "should not load the descMetadata datastream when calling content_changed?" do
      @obj.inner_object.repository.should_not_receive(:datastream_dissemination).with(hash_including(:dsid=>'descMetadata'))
      subject.should_not be_content_changed
    end

    it "should allow asserting an empty string" do
      subject.title = ['']
      subject.title.should == ['']
    end

    describe "when multivalue: false" do
      it "should return single values" do
        subject.description = 'my description'
        subject.description.should == 'my description'
      end
    end

    it "should clear stuff" do
      subject.title = ['one', 'two', 'three']
      subject.title.clear
      subject.graph.query([subject.rdf_subject,  RDF::DC.title, nil]).first.should be_nil
    end

    it "should have a list of fields" do
      MyDatastream.fields.should == [:title, :description]
    end
  end

  describe "deserialize" do
    let(:ds) { ActiveFedora::NtriplesRDFDatastream.new }
    subject { ds.deserialize(data) }

    context "with non-utf-8 characters" do
      # see https://github.com/ruby-rdf/rdf/issues/142
      let(:data) { "<info:fedora/scholarsphere:qv33rx50r> <http://purl.org/dc/terms/description> \"\\n\xE2\x80\x99 \" .\n".force_encoding('ASCII-8BIT') }

      it "should be able to handle non-utf-8 characters" do
        expect(subject.dump(:ntriples)).to eq "<info:fedora/scholarsphere:qv33rx50r> <http://purl.org/dc/terms/description> \"\\n’ \" .\n"
      end
    end

    context "when the object is saved and has no content in the datastream" do
      let(:data) { nil }
      before do
        allow(ds).to receive(:new?).and_return(false);
        allow(ds).to receive(:datastream_content).and_return(nil);
      end
      it "should return an empty graph" do
        expect(subject).to be_kind_of RDF::Graph
      end
    end
  end

  describe 'content=' do
    let(:ds) {ActiveFedora::NtriplesRDFDatastream.new}
    it "should be able to handle non-utf-8 characters" do
      data = "<info:fedora/scholarsphere:qv33rx50r> <http://purl.org/dc/terms/description> \"\\n\xE2\x80\x99 \" .\n".force_encoding('ASCII-8BIT')
      ds.content = data
      expect(ds.resource.dump(:ntriples)).to eq "<info:fedora/scholarsphere:qv33rx50r> <http://purl.org/dc/terms/description> \"\\n’ \" .\n"
    end
    context "when passed an IO-like object" do
      let(:file) { File.new(File.join(File.dirname(__FILE__), "..", "fixtures", "dublin_core_rdf_descMetadata.nt")) }
      it "should read it" do
        ds.content = file
        expect(ds.resource.dump(:ntriples)).to eq File.read(file.path)
      end
    end
  end

  describe 'legacy non-utf-8 characters' do
    let(:ds) do
      datastream = ActiveFedora::NtriplesRDFDatastream.new
      datastream.stub(:new?).and_return(false)
      datastream.stub(:datastream_content).and_return("<info:fedora/scholarsphere:qv33rx50r> <http://purl.org/dc/terms/description> \"\\n\xE2\x80\x99 \" .\n".force_encoding('ASCII-8BIT'))
      datastream
    end
    it "should not error on access" do
      expect(ds.resource.dump(:ntriples)).to eq "<info:fedora/scholarsphere:qv33rx50r> <http://purl.org/dc/terms/description> \"\\n’ \" .\n"
    end
  end

end
