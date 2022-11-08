# frozen_string_literal: true

Fabricator(:export) do
  export_type { :notices }
  interval    { 1 }
end
