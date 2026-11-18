# frozen_string_literal: true

require "spec_helper"

describe "apidocs", type: :request do
  it "documents photo attachment IDs and the scoped deletion response" do
    get apidocs_path(format: :json)

    expect(response).to be_ok
    schema = response.parsed_body
    photo_id = schema.fetch("definitions").fetch("Notice").fetch("properties").fetch("photos").fetch("items").fetch("properties").fetch("id")
    expect(photo_id).to include("type" => "integer", "format" => "int64", "readOnly" => true)

    operation = schema.fetch("paths").fetch("/notices/{token}/photos/{photo_id}").fetch("delete")
    expect(operation.fetch("parameters")).to include(
      a_hash_including("name" => "photo_id", "in" => "path", "type" => "integer", "required" => true),
    )
    expect(operation.fetch("responses").fetch("200").fetch("schema")).to eq("$ref" => "#/definitions/Notice")
    expect(operation.fetch("responses").fetch("404").fetch("schema")).to eq("$ref" => "#/definitions/Error")
  end
end
