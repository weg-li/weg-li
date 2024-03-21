# frozen_string_literal: true

class User::ExportsController < ApplicationController
  def index
    @exports = current_user.exports.order(params[:order] || "created_at DESC").with_attached_archive.page(params[:page])
  end

  def generate_export
    export_type = params[:export][:export_type] || :photos
    interval = params[:export][:interval] || Date.today.cweek

    Scheduled::ExportJob.perform_later(export_type:, interval:)
    redirect_to exports_path, notice: "Export #{export_type}/#{interval} wurde gestartet, es kann einige Minuten Dauern bis dieser hier erscheint."
  end
end
