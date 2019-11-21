include ActionDispatch::TestProcess

Fabricator(:bulk_upload) do
  photos { [fixture_file_upload(Rails.root.join('spec/support/assets/mercedes.jpg'), 'image/jpeg')] }
  user
  status { :open }
end
