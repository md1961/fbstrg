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

      if params[:no_announce]
        session[:no_announce] = params[:no_announce] == 'true'
      end
      @no_announce = session[:no_announce]

      if params[:speed]
        session[:speed_of_announce] = params[:speed].to_f
      end
      @speed_of_announce = session[:speed_of_announce]
    end

  private

    def trait_names
      @__trait_names ||= TeamTrait.first.attributes.keys.reject { |name|
        %w[id team_id created_at updated_at].include?(name)
      }
    end
    helper_method :trait_names
end
