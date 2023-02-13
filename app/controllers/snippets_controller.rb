# frozen_string_literal: true

class SnippetsController < ApplicationController
  before_action :authenticate!

  def index
    @table_params = { search: {}, order: {} }

    @snippets = current_user.snippets.page(params[:page])

    search = params[:search]
    if search.present?
      @table_params[:search] = search.to_unsafe_hash
      @snippets = @snippets.search(search[:term]) if search[:term].present?
    end

    order = params[:order]
    if order.present?
      @table_params[:order] = order.to_unsafe_hash
      if order[:column].present? && order[:value].present?
        @snippets = @snippets.reorder(order[:column] => order[:value])
      end
    end
  end

  def new
    @snippet = current_user.snippets.build
  end

  def show
    @snippet = current_user.snippets.find(params[:id])
  end

  def create
    @snippet = current_user.snippets.build(snippet_params)

    if @snippet.save
      respond_to do |format|
        format.js { render(layout: false) }
        format.html do
          redirect_to(snippets_path, notice: "Vorlage wurde angelegt")
        end
      end
    else
      render(:new)
    end
  end

  def edit
    @snippet = current_user.snippets.find(params[:id])
  end

  def update
    @snippet = current_user.snippets.find(params[:id])

    if @snippet.update(snippet_params)
      redirect_to(snippets_path, notice: "Vorlage wurde gespeichert")
    else
      render(:edit)
    end
  end

  def destroy
    snippet = current_user.snippets.find(params[:id])
    snippet.destroy!

    redirect_to(snippets_path, notice: "Vorlage wurde gelöscht")
  end

  private

  def snippet_params
    params.require(:snippet).permit(:name, :content, :priority)
  end
end
