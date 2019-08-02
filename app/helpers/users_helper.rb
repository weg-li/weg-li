module UsersHelper
  def gravatar(user)
    image_tag "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email.strip.downcase)}", alt: user.nickname, title: user.nickname, class: 'gravatar'
  end
end
