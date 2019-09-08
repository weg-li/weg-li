Rails.application.config.active_storage.analyzers.prepend(EXIFAnalyzer)

ActiveStorage.service_urls_expire_in = 1.week
