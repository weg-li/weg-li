Rails.application.config.active_storage.analyzers.prepend(EXIFAnalyzer)
Rails.application.config.active_storage.analyzers.prepend(Thumbnailer)

ActiveStorage.service_urls_expire_in = 1.week
