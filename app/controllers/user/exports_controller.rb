# frozen_string_literal: true

class User::ExportsController < ApplicationController
  before_action :authenticate!

  def index
    @exports = current_user.exports.order(params[:order] || "created_at DESC").with_attached_archive.page(params[:page])
  end

  def create
    export = current_user.exports.create(export_params)

    UserExportJob.perform_later(export)
    redirect_to user_exports_path, notice: "Export wurde gestartet, es kann einige Minuten Dauern bis dieser hier erscheint. Du erhältst eine E-Mail sobald der Export fertig ist."
  end

  def destroy
    export = current_user.exports.find(params[:id])
    export.destroy!

    redirect_to user_exports_path, notice: "Der Export wurde gelöscht."
  end

  private

  def export_params
    params.require(:export).permit(:export_type, :file_extension)
  end
end
