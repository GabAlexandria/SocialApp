class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

 def facebook

  @user = User.find_or_create_facebook_user(request.env["omniauth.auth"])

  if @user.persisted?
    @user.delay.get_location_from_facebook
    @user.delay.get_likes_from_facebook
    sign_in_and_redirect @user, :event => :authentication 
  else
    session["devise.facebook_data"] = request.env["omniauth.auth"]
    redirect_to new_user_registration_url 
  end

 end 

end
