require 'spec_helper'

describe ActiveFedora::SparqlInsert do
  let(:change_set) { ActiveFedora::ChangeSet.new(base, base.resource, base.changed_attributes.keys) }
  let(:repo_url) do
    repo_url = ActiveFedora.fedora.host + ActiveFedora.fedora.base_path
    repo_url.chomp!('/')
    repo_url
  end
  subject { ActiveFedora::SparqlInsert.new(change_set.changes) }

  context "with a changed object" do
    before do
      class Library < ActiveFedora::Base
      end

      class Book < ActiveFedora::Base
        belongs_to :library, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.hasConstituent
        property :title, predicate: ::RDF::DC.title
      end

      base.library_id = 'foo'
      base.title = ['bar']
    end
    after do
      undefine(:Library)
      undefine(:Book)
    end

    let(:base) { Book.create }


    it "should return the string" do
      expected = <<END
DELETE { <> <info:fedora/fedora-system:def/relations-external#hasConstituent> ?change . }
  WHERE { <> <info:fedora/fedora-system:def/relations-external#hasConstituent> ?change . } ;
DELETE { <> <http://purl.org/dc/terms/title> ?change . }
  WHERE { <> <http://purl.org/dc/terms/title> ?change . } ;
INSERT { \n<> <info:fedora/fedora-system:def/relations-external#hasConstituent> <#{repo_url}/foo> .
<> <http://purl.org/dc/terms/title> \"bar\" .\n}\n WHERE { }
END
      expect(subject.build).to eq expected.chomp
    end
  end
end
