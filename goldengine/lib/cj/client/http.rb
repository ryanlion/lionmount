require 'excon'

module CJ 

  class HTTP
    #include AppCara::Utils::Logging

    def initialize(api_key, url, persistent=false)
      @url = url
      @api_key = api_key
      @excon = Excon.new(url)
      @persistent = persistent
    end

    def persistent?
      @persistent
    end

    def reset
      @excon.reset
    end

    def request(params)
      final_url = @url+params[:path]
      debugger
      if params[:method]==:get
        response = Excon.get(final_url, :headers => {'authorization' => @api_key})
      else
        response = Excon.post(final_url,
                 :body => params[:body],
                 :headers => { "Content-Type" => "text/xml", "Accept" => "text/xml","Cookie" => "session="+(params[:session]||"") })
      end
    ensure
      reset unless @persistent
    end

  end
end
