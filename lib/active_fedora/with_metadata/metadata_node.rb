module ActiveFedora
  module WithMetadata
    class MetadataNode < ActiveTriples::Resource
      include ActiveModel::Dirty
      attr_reader :file

      def initialize(file)
        @file = file
        super(file.uri, ldp_source.graph)
      end

      def metadata_uri= uri
        @metadata_uri = uri
      end

      def metadata_uri
        @metadata_uri ||= if file.new_record?
          ::RDF::URI.new nil
        else
          raise "#{file} must respond_to described_by" unless file.respond_to? :described_by
          file.described_by
        end
      end

      def set_value(*args)
        super
        attribute_will_change! args.first
      end

      def ldp_source
        @ldp_source ||= begin
          rs =  LdpResource.new(ldp_connection, metadata_uri)
          unless file.new_record?
            # until Faraday can deal with null param encoding correctly, use POR HTTP
            uri = URI(metadata_uri)
            req = Net::HTTP::Get.new(uri)
            req.basic_auth ActiveFedora.fedora.user, ActiveFedora.fedora.password if ActiveFedora.fedora.user
            rdf = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req)}
            puts rdf.body
            stmts = ::RDF::Reader.for(content_type: rdf['Content-Type']).new(rdf.body)
            stmts.each {|stmt| rs.graph << ::RDF::Statement.new(::RDF::URI(file.uri),stmt.predicate,stmt.object)}
          end
          rs
        end
      end

      def ldp_connection
        ActiveFedora.fedora.connection
      end

      def save
        raise "Save the file first" if file.new_record?
        change_set = ChangeSet.new(self, self, changed_attributes.keys)
        # until Faraday can deal with null param encoding correctly, use POR HTTP
        uri = URI(metadata_uri)
        req = Net::HTTP::Patch.new(uri)
        req.basic_auth ActiveFedora.fedora.user, ActiveFedora.fedora.password if ActiveFedora.fedora.user
        req['Content-Type'] = "application/sparql-update"
        req.body = SparqlInsert.new(change_set.changes, ::RDF::URI.new(nil)).build
        res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req)}
        @ldp_source = nil
        true
      end

      class << self
        def parent_class= parent
          @parent_class = parent
        end

        def parent_class
          @parent_class
        end

        def property(name, options)
          parent_class.delegate name, :"#{name}=", :"#{name}_changed?", to: :metadata_node
          super
        end

        def create_delegating_setter(name)
          file.class.delegate(name, to: :metadata_node)
        end

        def exec_block(&block)
          class_eval &block
        end
      end
    end
  end
end
