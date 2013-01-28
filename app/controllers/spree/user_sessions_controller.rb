class Spree::UserSessionsController < Devise::SessionsController
  include SslRequirement
  helper 'spree/users', 'spree/base'
  if defined?(Spree::Dash)
    helper 'spree/analytics'
  end

  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Common
  include Spree::Core::ControllerHelpers::Order

  ssl_required :new, :create, :destroy, :update
  ssl_allowed :login_bar

  def create
    authenticate_user!

    if user_signed_in?
      respond_to do |format|
        format.html {
          flash[:success] = t(:logged_in_succesfully)
          redirect_back_or_default(root_path)
        }
        format.js {
          user = current_user
          render :json => {:ship_address => user.ship_address, :bill_address => user.bill_address}
        }
      end
    else
      flash.now[:error] = t('devise.failure.invalid')
      format.html {
        render :new
      }
      format.js {
        render :json => {:erros  => 'bad-credentials'}, status: 401
      }
    end
  end

  def destroy
    cookies.clear
    session.clear
    super
  end

  def nav_bar
    render :partial => 'spree/shared/nav_bar'
  end

  private
  def accurate_title
    t(:login)
  end

  def redirect_back_or_default(default)
    redirect_to(session["user_return_to"] || default)
    session["user_return_to"] = nil
  end
end
