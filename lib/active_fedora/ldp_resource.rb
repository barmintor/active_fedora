module ActiveFedora
  class LdpResource < Ldp::Resource::RdfSource
    def build_empty_graph
      graph_class.new(subject_uri)
    end

    def self.graph_class
      ActiveTriples::Resource
    end

    def graph_class
      self.class.graph_class
    end

    ##
    # @param [RDF::Graph] original_graph The graph returned by the LDP server
    # @return [RDF::Graph] A graph striped of any inlined resources present in the original
    def build_graph(original_graph)
      inlined_resources = get.graph.query(predicate: Ldp.contains).map { |x| x.object }

      # ActiveFedora always wants to copy the resources to a new graph because it
      # forces a cast to FedoraRdfResource
      graph_without_inlined_resources(original_graph, inlined_resources)
    end
    #OVERRIDES FOR ETAGS
    ##
    # Update the stored graph
    def update new_content = nil
      new_content ||= content
      resp = client.put subject, new_content do |req|
        etag = (retrieved_content?) ? get.etag : head.headers['ETag']
        req.headers['If-Match'] = etag if etag
        yield req if block_given?
      end
      update_cached_get(resp) if retrieved_content?
      resp
    end
    ##
    # Delete the resource
    def delete
      client.delete subject do |req|
        etag = (retrieved_content?) ? get.etag : head.headers['ETag']
        req.headers['If-Match'] = etag if etag
      end
    end
  end
end
