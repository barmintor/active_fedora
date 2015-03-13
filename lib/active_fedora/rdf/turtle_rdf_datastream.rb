require 'rdf/turtle'

module ActiveFedora
  class TurtleRDFDatastream < RDFDatastream
    def self.default_attributes
      super.merge(:mimeType => 'text/turtle')
    end

    def serialization_format
      :ttl
    end
  end
end

