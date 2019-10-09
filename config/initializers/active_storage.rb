Rails.application.config.active_storage.analyzers.prepend(EXIFAnalyzer)
Rails.application.config.active_storage.analyzers.prepend(Thumbnailer)

ActiveStorage.service_urls_expire_in = 1.week

ActiveStorage::DirectUploadsController.instance_eval do
  rescue_from(ActionController::InvalidAuthenticityToken, with: lambda { redirect_to('/', alert: 'Ihre Sitzung ist abgelaufen') })
end
