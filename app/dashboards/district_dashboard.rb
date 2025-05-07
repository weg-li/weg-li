require "administrate/base_dashboard"

class DistrictDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    email: Field::String,
    name: Field::String,
    zip: Field::String,
    prefixes: Field::String,
    state: Field::String,
    osm_id: Field::Number,
    aliases: Field::String,
    parts: Field::String,
    latitude: Field::Number.with_options(decimals: 2),
    longitude: Field::Number.with_options(decimals: 2),
    flags: Field::Number,
    config:  Field::String.with_options(searchable: false),
    status:  Field::String.with_options(searchable: false),
    ags: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :name,
    :zip,
    :email,
    :status,
    :config,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :email,
    :zip,
    :prefixes,
    :aliases,
    :parts,
    :state,
    :osm_id,
    :latitude,
    :longitude,
    :flags,
    :config,
    :status,
    :ags,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :name,
    :email,
    :zip,
    :aliases,
    :parts,
    :prefixes,
    :state,
    :osm_id,
    :flags,
    :config,
    :status,
    :ags,
  ].freeze

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(resource)
    resource.display_name
  end
end
