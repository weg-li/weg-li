module LoginHelper
  def login(user = Fabricate(:user))
    get "/auth/offline_login/#{CGI.escape(user.nickname).gsub('.', '%2E')}"

    user
  end

  def logout
    get logout_path
  end
end
