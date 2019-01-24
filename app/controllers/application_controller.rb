class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure

  protected

    def configure
      if params[:real]
        session[:body_class] = params[:real] == 'true' ? 'real' : nil
      end
      @body_class = session[:body_class]

      if params[:speed]
        session[:speed_of_announce] = params[:speed].to_f
      end
      @speed_of_announce = session[:speed_of_announce]
    end
end
