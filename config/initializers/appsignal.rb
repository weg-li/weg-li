if Rails.env.production?
  Rails.logger = ActiveSupport::TaggedLogging.new(Appsignal::Logger.new("rails"))
end
