# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found
    respond_to { |format| format.html { render status: 404 } }
  end

  def unacceptable
    respond_to { |format| format.html { render status: 422 } }
  end

  def internal_error
    respond_to { |format| format.html { render status: 500 } }
  end
end
