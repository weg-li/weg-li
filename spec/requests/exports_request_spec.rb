require 'rails_helper'

describe "exports", type: :request  do
  describe "GET /exports" do
    it "works!" do
      get exports_path

      expect(response).to be_successful
      assert_select 'h2', 'weg-li Falschparker-Exporte'
    end
  end
end
