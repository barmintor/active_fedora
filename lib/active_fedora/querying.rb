module ActiveFedora
  module Querying
    delegate :find, :first, :exists?, :where, :limit, :order, :delete_all, 
      :destroy_all, :count, :last, :find_with_conditions, :find_in_batches, :find_each, :to=>:all

    def self.extended(base)
      base.class_attribute  :solr_query_handler
      base.solr_query_handler = 'standard'
    end

    def default_sort_params
      [ActiveFedora::SolrService.solr_name(:system_create, :stored_sortable, type: :date)+' asc'] 
    end

    def quote_for_solr(value)
      '"' + value.gsub(/(:)/, '\\:').gsub(/(\/)/, '\\/').gsub(/"/, '\\"') + '"'
    end
  end
end
