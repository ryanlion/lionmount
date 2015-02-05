module CJ
  class APIClient 
    @protocol = "https"
    @advertisterhost= "advertiser-lookup.api.cj.com"
    @commissionhost= "commission-detail.api.cj.com"
    @producthost= "product-search.api.cj.com"

    def self.advertiser_look_up(args)
        @api = ::CJ::API.new(@protocol, @advertisterhost)
        @api.advertiser.advertiser_look_up(args)
    end

    def self.commission_details(args)
        @api = ::CJ::API.new(@protocol, @commissionhost)
        @api.commission.commission_details(args)
    end
    
    def self.product_search(args)
        @api = ::CJ::API.new(@protocol, @producthost)
        @api.product.product_search(args)
    end
  end
end
# it should not be loaded in all environment
# require 'debugger'
require 'ostruct'
require_relative 'cj/client/client.rb'
