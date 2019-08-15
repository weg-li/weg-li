module UsersHelper
  def gravatar(user)
    image_tag "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email.strip.downcase)}", alt: user.name, title: user.name, class: 'gravatar'
  end
end
