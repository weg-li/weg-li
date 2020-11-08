Fabricator(:bulk_upload) do
  photos { [Rack::Test::UploadedFile.new(Rails.root.join('spec/support/assets/mercedes.jpg'), 'image/jpeg')] }
  user
  status { :open }
end
