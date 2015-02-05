module CJ 

  # Address (Restful API)
  class Commission

    # initialize a new instance of Authenticaiton
    #
    # @param connection [Authentication::Connection]
    def initialize(connection)
      @connection = connection
    end

    # Lists all addresses from the target’s domain address list.
    #
    # @param session [String]
    # @param domain_id [String] Target domain
    # @param use_configuration_limit	[Boolean]If active limits the list, according to your mps.conf settings.
    def commission_details(args)
      result = @connection.rest_request(
        method: :get,
        path: "/commissions/?#{args}",
      )
      xml = result.body
      return Hash.from_xml(xml).to_json
    end

   
  end # of class
end # of module
