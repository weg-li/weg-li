require "administrate/base_dashboard"

class NoticeDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    photos: Field::ActiveStorage.with_options(destroy_url: nil),
    id: Field::Number.with_options(searchable: true),
    meta: Field::String.with_options(searchable: false),
    token: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    status: Field::String.with_options(searchable: false),
    flags: Field::Number,
    date: Field::DateTime,
    district: Field::BelongsTo,
    charge: Field::String,
    brand: Field::String,
    color: Field::String,
    registration: Field::String,
    location: Field::String,
    street: Field::String,
    zip: Field::String,
    city: Field::String,
    duration: Field::Number,
    severity: Field::String.with_options(searchable: false),
    latitude: Field::Number.with_options(decimals: 2),
    longitude: Field::Number.with_options(decimals: 2),
    incomplete: Field::Boolean,
    note: Field::String,
    replies: Field::HasMany,
    data_sets: Field::HasMany,
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
    :status,
    :user,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user,
    :id,
    :token,
    :created_at,
    :updated_at,
    :status,
    :incomplete,
    :registration,
    :brand,
    :color,
    :district,
    :street,
    :zip,
    :city,
    :location,
    :charge,
    :date,
    :duration,
    :severity,
    :note,
    :flags,
    :latitude,
    :longitude,
    :photos,
    :meta,
    :data_sets,
    :replies,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user,
    :status,
    :registration,
    :brand,
    :color,
    :district,
    :street,
    :zip,
    :city,
    :location,
    :charge,
    :date,
    :duration,
    :severity,
    :note,
    :flags,
    :latitude,
    :longitude,
  ].freeze

  # Overwrite this method to customize how notices are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(notice)
    "Notice ##{notice.id}"
  end
end
