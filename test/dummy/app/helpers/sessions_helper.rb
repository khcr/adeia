module SessionsHelper

  # Sign in a user with a cookie (remove on browser close)
  # 
  # * *Args*    :
  #   - a user to sign in
  # * *Returns* :
  #
  def sign_in(user, permanent: false)
    cookies[:remember_token] = { value: user.remember_token, expires: (Time.now + 2592000 if permanent) }
    self.current_user = user
  end

  def current_user=(user)
    @current_user = user
  end

  # Provid the user currently signed in.
  # 
  # * *Returns* :
  #   - the user currently signed in
  def current_user
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end

  # Sign out a user by removing the cookie.
  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end

end