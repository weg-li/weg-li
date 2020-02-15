class RepliesController < ApplicationController
  before_action :authenticate!

  def index
    @table_params = {
      search: {},
      order: {},
    }

    @replies = current_user.replies.page(params[:page])

    if search = params[:search]
      @table_params[:search] = search.to_unsafe_hash
      @replies = @replies.search(search[:term]) if search[:term].present?
    end
    if order = params[:order]
      @table_params[:order] = order.to_unsafe_hash
      if order[:column].present? && order[:value].present?
        @replies = @replies.reorder(order[:column] => order[:value])
      end
    end
  end
end
