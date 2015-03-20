module ActiveFedora
  class Fedora
    def initialize(config)
      @config = config
      init_base_path
    end

    def host
      @config[:url]
    end

    def base_path
      @config[:base_path] || '/'
    end

    def user
      @config[:user]
    end

    def password
      @config[:password]
    end

    def connection
      @connection ||= CachingConnection.new(authorized_connection)
    end

    def ldp_resource_service
      @service ||= LdpResourceService.new(connection)
    end

    def reuses_uris?
      !(@config[:reuse_uris] == false)
    end

    def uri_property(key)
      ::RDF::URI(@config[key])
    end
    SLASH = '/'.freeze
    BLANK = ''.freeze

    # Call this to create a Container Resource to act as the base path for this connection
    def init_base_path
      segs = root_resource_path.split('/')
      ensure_resource('',nil)
      ensure_resource(segs[0],nil)
      1.upto(segs.size - 1) do |ix|
        ensure_resource(segs[0...ix].join('/'),segs[ix])
      end
    end

    # Remove a leading slash from the base_path
    def root_resource_path
      @root_resource_path ||= base_path.sub(SLASH, BLANK)
    end

    def authorized_connection
      connection = Faraday.new(host)
      connection.basic_auth(user, password)
      connection
    end

    def ensure_resource(path,uri,ixm='http://www.w3.org/ns/ldp#DirectContainer')
      connection.head(uri ? (path + '/' + uri) : path)
      ActiveFedora::Base.logger.info "Attempted to init base path `#{path}`, but it already exists" if ActiveFedora::Base.logger
      false
    rescue Ldp::NotFound
      if !host.downcase.end_with?("/rest")
        if ActiveFedora::Base.logger
          ActiveFedora::Base.logger.warn "Fedora URL (#{host}) does not end with /rest. This could be a problem. Check your fedora.yml config"
        end
      end
      if uri
        r = connection.post(path, "<> a <#{ixm}>.") do |req|
          req.headers['Link'] = ["<#{ixm}>; rel=\"type\""]
          req.headers['Slug'] = uri
        end
        r.success?
      else
        r = connection.put(path, "<> a <#{ixm}>.") { |req| req.headers['Link'] = ["<#{ixm}>; rel=\"type\""]}
      end
    end

  end
end
