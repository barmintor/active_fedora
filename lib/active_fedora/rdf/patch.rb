module ActiveFedora
  module RDF
    class Patch
      attr_reader :changes, :subject

      def initialize(changes, subject = ::RDF::URI.new(nil))
        @changes = changes
        @subject = subject
      end

      def execute(uri)
        result = ActiveFedora.fedora.connection.patch(uri, build, "Content-Type" => "application/sparql-update")
        return true if result.status == 204
        raise "Problem updating #{result.status} #{result.body}"
      end

      def build
        query = deletes(subject)
          changes.map do |_, result|
            result.map do |statement|
              query << "A " +
              ::RDF::Query::Pattern.new(subject: subject, predicate: statement.predicate, object: statement.object).to_s
            end
          end.join(".")
        query.join("\n")
      end

      private

      def deletes(subject)
        patterns(subject).map do |pattern|
          "D #{pattern} ."
        end
      end

      def patterns(subject)
        changes.map do |key, _|
          ::RDF::Query::Pattern.new(subject, key, :change).to_s
        end
      end
    end
  end
end