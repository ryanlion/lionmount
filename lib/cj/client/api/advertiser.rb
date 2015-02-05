module CJ 

  # Address (Restful API)
  class Advertiser

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
    def advertiser_look_up(args)
      result = @connection.rest_request(
        method: :get,
        path: "/advertiser-lookup/?#{args}",
      )
      xml = result.body
      return Hash.from_xml(xml).to_json
    end

    # Adds a list of addresses to the address list associated with an existing domain.
    #
    # @param params [Hash]
    # @example sample: 
    # params[:session] = session
    # params[:domain_id] = "xxxxxx-xxxx-xxxxxx"
    # params[:address] = ["abc@abc.com","abcd@abc.com"]
    # params[:import_type] = "append" --import type value should be either "append" or "replace"
    def add_address(params)
      ad = AnubisNetwork::Model::AddAddress.new
      ad_arr = Array.new
      ad.domain_id = params[:domain_id]
      params[:address].each do |address|
        add = AnubisNetwork::Model::Address.new
        add.address = address
        ad_arr.push(add)
      end

      ad.address = ad_arr
      ad.import_type = params[:import_type]
      payload = ad.to_xmldoc_r
      result = @connection.rest_request(
        method: :post,
        path: "/mps_setup/add_address/",
        body: payload,
        session: params[:session]
      )
      xml = result.body.sub(/(?<=\<n:add_addressResponse).*?(?=\>)/,"")
      xml = xml.gsub(/(?=n:add_addressResponse).*?(?=\>)/,"add_addressResponse")
      return Hash.from_xml(xml).to_json

    end

    # Deletes a domain from the MPS platform.
    def delete_domain(session,id)
      result = @connection.rest_request(
        method: :get,
        path: "/mps_setup/delete_domain/#{id}",
        session: session
      )
      xml = result.body.sub(/(?<=\<n:delete_domainResponse).*?(?=\>)/,"")
      xml = xml.gsub(/(?=n:delete_domainResponse).*?(?=\>)/,"delete_domainResponse")
      return Hash.from_xml(xml).to_json
    end

    # Gets the settings associated with a domain.
    def get_domain(session,id)
      result = @connection.rest_request(
        method: :get,
        path: "/mps_setup/get_domain/#{id}",
        session: session
      )
      xml = result.body.sub(/(?<=\<n:get_domainResponse).*?(?=\>)/,"")
      xml = xml.gsub(/(?=n:get_domainResponse).*?(?=\>)/,"get_domainResponse")
      return Hash.from_xml(xml).to_json
    end

    # Gets the settings associated with a domain.
    def activate_domain(session,id,active)
      result = @connection.rest_request(
        method: :get,
        path: "/mps_setup/activate_domain/#{id}/#{active}",
        session: session
      )
      xml = result.body.sub(/(?<=\<n:activate_domainResponse).*?(?=\>)/,"")
      xml = xml.gsub(/(?=n:activate_domainResponse).*?(?=\>)/,"activate_domainResponse")
      return Hash.from_xml(xml).to_json
    end
  end # of class
end # of module
