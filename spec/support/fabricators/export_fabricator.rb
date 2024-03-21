# frozen_string_literal: true

Fabricator(:export) do
  export_type { :notices }
  archive { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/notice_export.zip"), "application/zip") }
  user { nil }
end
