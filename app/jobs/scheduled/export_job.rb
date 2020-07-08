require 'csv'
require 'zip'

class Scheduled::ExportJob < ApplicationJob
  def perform(export_type: :notices, interval: Date.today.cweek)
    Rails.logger.info("create export for type #{export_type} in week #{interval}")

    export = Export.new(export_type: export_type, interval: interval)
    name = export.display_name.parameterize

    archive = Zip::OutputStream.write_buffer do |stream|
      stream.put_next_entry("#{name}.csv")
      stream.print export.header.to_csv
      export.data.in_batches do |batch|
        batch.each do |data|
          stream.print data.open_data.to_csv
        end
      end
    end
    archive.rewind

    export.save!
    export.archive.attach(io: archive, filename: "#{name}.zip", content_type: 'application/zip')
  end
end
