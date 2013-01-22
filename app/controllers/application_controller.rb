class ApplicationController < ActionController::Base
  before_filter :get_stream_status

  def forem_user
    current_user
  end
  helper_method :forem_user

  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => "You do not have permission to access that page"
  end

  protected
    def redirect_to_root_or_last_location(notice)
      if session[:redirect_to] && !session[:redirect_to].downcase.start_with?("#{request.protocol.downcase}#{request.host.downcase}")
        session[:redirect_to] = nil  # Only redirect to urls within the site
      end
      if session[:redirect_to] == register_url
        session[:redirect_to] = nil  # Don't return back to the register page if the user is logged in
      end

      success_url = session[:redirect_to] || root_url(:protocol => 'http')
      redirect_to success_url, :notice => notice
      session[:redirect_to] = nil
    end

	private
    def current_user
    	@current_user ||= User.find_by_auth_token(cookies[:auth_token]) if cookies[:auth_token]
    end

    helper_method :current_user

    def get_stream_status
      @streams = {:maximusblack => Stream.maximusblack.live,
                  :novawar      => Stream.novawar.live,
                  :lagtv        => Stream.lagtv.live}
    end
end
