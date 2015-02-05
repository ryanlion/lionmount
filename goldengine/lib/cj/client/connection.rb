require 'excon'
#require 'savon'
require_relative 'http'
require_relative 'model/base'

module CJ

  # API connection to AnubisNetwork
  class Connection
    #include AppCara::Utils::Logging

    # initialize a new instance of API connection to AnubisNetwork
    #
    # @param protocol [String] http or https
    # @param host [String] Host or IP address
    def initialize(protocol, host)
      @rest_url = "#{protocol}://#{host}/v3"
      @api_key = "008705e3847989f1cdb275ca55832d5a83d3afcb41fade90bd16776dd76eb80a4b0ff1d050391be1433c0027ceeee34c24cccceb563670bba00c31319f575b64c1/700d1801d127040ef321c356f1b48aa049e562658ffe71d929b2d4e9ea8d3aa457477106b67565d647d5a77f9286b8c0d3882addc662dc5b3f7dfb60fc79a3bd"
      @rest_connection = CJ::HTTP.new(@api_key,@rest_url)
    end

    def rest_request(options)
      params = {}
      params[:method] = options[:method]
      params[:path] = options[:path]
      params[:session] = options[:session]
      params[:body] = options[:body] unless options[:body].blank?
      # try to make the API call
      tries = 3
      begin
        response = @rest_connection.request(params)
      rescue Excon::Errors::Timeout
        raise
      rescue Exception => err
        #applog :error, err
        raise "Network Error: #{err.message}"
      end
      # try to parse the error message
      begin
        if response.status == 200 then
          response
        else
          err = CJ::Model::SystemError.from_xml(response.body)
          # TODO: show out response.body?
          raise "CJ API Server returns http code: #{response.status}: #{err.message}"
        end
      rescue => ex
        #applog :error, ex
        raise
      end
    end

  end # of class
end # of module
