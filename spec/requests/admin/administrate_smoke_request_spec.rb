# frozen_string_literal: true

require "spec_helper"

describe "admin/administrate smoke", type: :request do
  let(:admin) { Fabricate(:user, access: :admin) }

  before do
    login(admin)
  end

  it "renders all administrate index and show pages once" do
    admin_route_groups.each do |controller, routes|
      resource_name = controller.delete_prefix("admin/")

      get send(:"#{routes.fetch(:index)}_path")
      expect(response).to be_ok, "Expected #{routes.fetch(:index)} to be OK"

      record = build_admin_record(resource_name, admin:)
      get send(:"#{routes.fetch(:show)}_path", record)
      expect(response).to be_ok, "Expected #{routes.fetch(:show)}_path(#{record.class}##{record.id}) to be OK"
    end
  end

  def admin_route_groups
    @admin_route_groups ||= Rails.application.routes.routes.each_with_object({}) do |route, groups|
      next unless route.verb&.match?(/GET/)

      controller = route.defaults[:controller]
      action = route.defaults[:action]
      name = route.name&.to_sym

      next unless controller&.start_with?("admin/")
      next unless %w[index show].include?(action)
      next unless name

      groups[controller] ||= {}
      groups[controller][action.to_sym] = name
    end.select { |_controller, routes| routes.key?(:index) && routes.key?(:show) }.sort.to_h
  end

  def build_admin_record(resource_name, admin:)
    case resource_name
    when "users"
      admin
    when "charge_variants"
      charge = Fabricate(:charge)
      ChargeVariant.create!(tbnr: charge.tbnr, table_id: 1, row_id: 1, row_number: 1, charge_detail: 2)
    else
      Fabricate(resource_name.singularize.to_sym)
    end
  end
end
