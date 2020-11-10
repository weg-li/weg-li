class BulkUploadUpdateJob < ApplicationJob
  def perform(bulk_upload)
    fail NotYetAnalyzedError unless bulk_upload.photos.all?(&:analyzed?)

    bulk_upload.update! status: :open
  end
end
