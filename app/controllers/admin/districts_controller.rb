module Admin
  class DistrictsController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = BulkUpload.
    #     page(params[:page]).
    #     per(10)
    # end

    def bulk_update
      District.where(email: params[:email]).update_all(
        email: params[:to_email],
        flags: params[:to_flags],
        config: params[:to_config],
        updated_at: Time.now.utc
      )

      redirect_to admin_districts_path(search: params[:to]), notice: "Bezirke '#{params[:email]}' wurde zu '#{params[:to_email]} #{params[:to_flags]} #{params[:to_config]}' geändert"
    end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   BulkUpload.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    def resource_params
      district = params.require(resource_name)
      district[:aliases] = normalize_list_param(district[:aliases])
      district[:prefixes] = normalize_list_param(district[:prefixes])
      district[:parts] = normalize_list_param(district[:parts])

      district.permit(
        *dashboard.permitted_attributes,
        aliases: [],
        prefixes: [],
        parts: [],
      )
    end

  end
end
