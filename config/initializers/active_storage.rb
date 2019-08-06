Rails.application.config.active_storage.analyzers.prepend(EXIFAnalyzer)

ActiveStorage::Service.url_expires_in = 1.week
