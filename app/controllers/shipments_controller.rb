class ShipmentsController < ApplicationController
    protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
    def create
        byebug
        render :text => "success"
    end
end
