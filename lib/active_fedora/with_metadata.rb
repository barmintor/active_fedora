module ActiveFedora
  module WithMetadata
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload

    autoload :MetadataNode

    def metadata_node
      @metadata_node ||= self.class.metadata_schema.new(self)
    end

    def save(*)
      if super
        metadata_node.metadata_uri = described_by # TODO only necessary if the URI was < > before
        metadata_node.save # TODO if changed?
      end
    end

    module ClassMethods
      def metadata(&block)
        metadata_schema.exec_block(&block)
      end

      def metadata_schema
        @metadata_schema ||= MetadataNodeClass(self)
      end

      # Make a subclass of MetadataNode named GeneratedMetadataSchema and set its
      # parent_class attribute to have the value of the current class.
      def MetadataNodeClass(parent_klass)
        klass = self.const_set(:GeneratedMetadataSchema, Class.new(MetadataNode))
        klass.parent_class = parent_klass
        klass
      end
    end
  end
end
