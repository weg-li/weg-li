SuckerPunch.exception_handler = -> (ex, klass, args) { ExceptionNotifier.notify_exception(ex) }
