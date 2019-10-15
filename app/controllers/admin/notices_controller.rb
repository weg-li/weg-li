module Admin
  class NoticesController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Notice.
    #     page(params[:page]).
    #     per(10)
    # end

    def analyze
      notice = Notice.from_param(params[:notice_id])
      notice.analyze!

      redirect_to admin_notice_path(notice), notice: "Analyse wurde gestartet"
    end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Notice.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
