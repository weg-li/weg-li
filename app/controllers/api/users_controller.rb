# frozen_string_literal: true

class Api::UsersController < Api::ApplicationController
  swagger_path "/user" do
    operation :get do
      key :summary, "Get own account and statistics"
      key :description,
          "Returns only the authenticated user's name, nickname, notice counts and personal charge usage. " \
          "Notice counts include archived notices; incomplete and archived counts overlap the status counts. " \
          "Charge usage counts all notices with status shared, including archived and manually reported notices. " \
          "There is no top-N cutoff. last_used_at is the latest sent_at, falling back to created_at for legacy notices. " \
          "Clients can combine count and last_used_at to rank personal choices by frequency and recency."
      key :tags, ["user"]
      response 200 do
        key :description, "own account response"
        schema { key :$ref, :User }
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def show
    response.headers["Cache-Control"] = "private, no-store"
    render json: AccountStatistics.new(current_user).to_h
  end
end
