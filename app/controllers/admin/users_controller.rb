module Admin
  class UsersController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    def login
      user = User.from_param(params[:user_id])
      sign_in_alias(user)

      redirect_to root_path, notice: "Signed in as #{user.name}"
    end

    def merge
      user = User.from_param(params[:user_id])
      source = User.find(params[:source_id])
      user.merge(source)

      redirect_to [:admin, user], notice: "Merged data from #{source.id}"
    end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   User.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
