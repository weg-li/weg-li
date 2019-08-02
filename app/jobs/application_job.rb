class ApplicationJob
  if Rails.env.test?
    def self.perform_async(*args)
      new.perform(*args)
    end
  else
    include SuckerPunch::Job
  end
end
