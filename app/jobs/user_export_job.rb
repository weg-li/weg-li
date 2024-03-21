# frozen_string_literal: true

require "zip"

class UserExportJob < ApplicationJob
  def perform(export)
    name = export.display_name.parameterize

    archive = Zip::OutputStream.write_buffer do |stream|
      stream.put_next_entry("#{name}.#{export.file_extension}")
      export.data { |data| stream.print(data.to_csv) }
    end
    archive.rewind

    export.save!
    export.archive.attach(
      io: archive,
      filename: "#{name}.zip",
      content_type: "application/zip",
    )

    UserMailer.export(export).deliver_later
  end
end
