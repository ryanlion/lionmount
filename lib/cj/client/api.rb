module CJ 
  # This class wraps the commonly used API call to Mail Protection Service
  class API

    attr_reader :advertiser
    attr_reader :commission
    attr_reader :product

    def initialize(protocol, host)
      @connection = CJ::Connection.new(protocol, host)
      @advertiser = CJ::Advertiser.new(@connection)
      @commission = CJ::Commission.new(@connection)
      @product = CJ::ProductSearch.new(@connection)
    end

  end # of class
end # of module

require_relative 'api/commission'
require_relative 'api/advertiser'
require_relative 'api/product-search'
