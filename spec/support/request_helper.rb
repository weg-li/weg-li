module RequestHelper
  def login(user = Fabricate(:user))
    @controller.send :sign_in, user
    user
  end

  def logout
    @controller.send :sign_out
  end
end
