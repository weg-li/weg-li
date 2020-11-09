# Define an application-wide HTTP feature policy. For further
# information see https://developers.google.com/web/updates/2018/06/feature-policy
#
Rails.application.config.feature_policy do |f|
  f.geolocation :self
  f.camera      :self
  f.gyroscope   :none
  f.microphone  :none
  f.usb         :none
  f.fullscreen  :none
  f.payment     :none
end
