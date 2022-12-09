# frozen_string_literal: true

class RepliesController < ApplicationController
  before_action :authenticate!

  def index
    @table_params = { search: {}, order: {} }

    @replies = current_user.replies.includes(:notice).page(params[:page])

    search = params[:search]
    if search.present?
      @table_params[:search] = search.to_unsafe_hash
      @replies = @replies.search(search[:term]) if search[:term].present?
    end

    order = params[:order]
    if order.present?
      @table_params[:order] = order.to_unsafe_hash
      if order[:column].present? && order[:value].present?
        @replies = @replies.reorder(order[:column] => order[:value])
      end
    end
  end
end
