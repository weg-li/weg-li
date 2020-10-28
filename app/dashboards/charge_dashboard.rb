require "administrate/base_dashboard"

class ChargeDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    tbnr: Field::String,
    description: Field::String,
    fine: Field::Number,
    bkat: Field::String,
    penalty: Field::String,
    fap: Field::String,
    points: Field::Number,
    valid_from: Field::DateTime,
    valid_to: Field::DateTime,
    implementation: Field::Number,
    classification: Field::Number,
    variant_table_id: Field::Number,
    rule_id: Field::Number,
    table_id: Field::Number,
    required_refinements: Field::String,
    number_required_refinements: Field::Number,
    max_fine: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :tbnr,
    :description,
    :valid_from,
    :valid_to,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :tbnr,
    :description,
    :fine,
    :bkat,
    :penalty,
    :fap,
    :points,
    :valid_from,
    :valid_to,
    :implementation,
    :classification,
    :variant_table_id,
    :rule_id,
    :table_id,
    :required_refinements,
    :number_required_refinements,
    :max_fine,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :tbnr,
    :description,
    :fine,
    :bkat,
    :penalty,
    :fap,
    :points,
    :valid_from,
    :valid_to,
    :implementation,
    :classification,
    :variant_table_id,
    :rule_id,
    :table_id,
    :required_refinements,
    :number_required_refinements,
    :max_fine,
  ].freeze

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(resource)
    resource.tbnr
  end
end
