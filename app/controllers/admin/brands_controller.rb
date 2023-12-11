module Admin
  class BrandsController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = BulkUpload.
    #     page(params[:page]).
    #     per(10)
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   BulkUpload.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    def resource_params
      params[:brand][:aliases] = params[:brand][:aliases].split(
        /;|,|\s/
      ).reject(&:blank?)
      params[:brand][:models] = params[:brand][:models].split(
        /;|,|\s/
      ).reject(&:blank?)
      params.require(resource_name).permit(
        *dashboard.permitted_attributes,
        aliases: [],
        models: []
      )
    end
  end
end
