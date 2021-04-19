class BulkUploadUpdateJob < ApplicationJob
  def perform(bulk_upload)
    fail NotYetAnalyzedError unless photos_analyzed?(bulk_upload)

    bulk_upload.update! status: :open
  end
end
