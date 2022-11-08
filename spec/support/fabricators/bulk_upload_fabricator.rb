# frozen_string_literal: true

Fabricator(:bulk_upload) do
  photos { [Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/mercedes.jpg'), 'image/jpeg')] }
  user
  status { :open }
end
