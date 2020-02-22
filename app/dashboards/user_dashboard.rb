require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    notices: Field::HasMany,
    authorizations: Field::HasMany,
    bulk_uploads: Field::HasMany,
    id: Field::Number,
    email: Field::String,
    nickname: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    token: Field::String,
    validation_date: Field::DateTime,
    access: Field::String.with_options(searchable: false),
    flags: Field::Number,
    name: Field::String,
    street: Field::String,
    zip: Field::String,
    city: Field::String,
    latitude: Field::Number.with_options(decimals: 2),
    longitude: Field::Number.with_options(decimals: 2),
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :token,
    :created_at,
    :nickname,
    :name,
    :access,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :email,
    :nickname,
    :created_at,
    :updated_at,
    :token,
    :validation_date,
    :access,
    :flags,
    :name,
    :street,
    :zip,
    :city,
    :latitude,
    :longitude,
    :notices,
    :authorizations,
    :bulk_uploads,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :email,
    :nickname,
    :token,
    :validation_date,
    :access,
    :flags,
    :name,
    :street,
    :zip,
    :city,
  ].freeze

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(user)
    user.nickname
  end
end
