# frozen_string_literal: true

Fabricator(:data_set) do
  setable(fabricator: :notice)
  data { { lorem: "ipsum" } }
  after_build { |data_set, _| data_set.keyable = data_set.setable.photos.first }
end
