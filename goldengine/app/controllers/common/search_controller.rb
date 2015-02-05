class Common::SearchController < ApplicationController 
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  def product_search
    begin
      products=CJ::APIClient.product_search("keywords="+params["keyword"])
      redirect_to(:back,
                  :notice => "Nate rule is created")
    rescue Exception => err
      redirect_to(:back,
                  :notice => "Create Nate rule has failed")
    end
  end
end
