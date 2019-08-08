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
    photos_attachments: Field::HasMany.with_options(class_name: "ActiveStorage::Attachment"),
    photos_blobs: Field::HasMany.with_options(class_name: "ActiveStorage::Blob"),
    id: Field::Number,
    data: Field::String.with_options(searchable: false),
    token: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    status: Field::String.with_options(searchable: false),
    flags: Field::Number,
    date: Field::DateTime,
    charge: Field::String,
    kind: Field::String,
    brand: Field::String,
    model: Field::String,
    color: Field::String,
    registration: Field::String,
    address: Field::String,
    latitude: Field::Number.with_options(decimals: 2),
    longitude: Field::Number.with_options(decimals: 2),
    incomplete: Field::Boolean,
    note: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :user,
    :photos_attachments,
    :photos_blobs,
    :id,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user,
    :photos_attachments,
    :photos_blobs,
    :id,
    :data,
    :token,
    :created_at,
    :updated_at,
    :status,
    :flags,
    :date,
    :charge,
    :kind,
    :brand,
    :model,
    :color,
    :registration,
    :address,
    :latitude,
    :longitude,
    :incomplete,
    :note,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user,
    :photos_attachments,
    :photos_blobs,
    :data,
    :token,
    :status,
    :flags,
    :date,
    :charge,
    :kind,
    :brand,
    :model,
    :color,
    :registration,
    :address,
    :latitude,
    :longitude,
    :incomplete,
    :note,
  ].freeze

  # Overwrite this method to customize how notices are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(notice)
  #   "Notice ##{notice.id}"
  # end
end
