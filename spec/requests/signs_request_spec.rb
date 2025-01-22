# frozen_string_literal: true

require "spec_helper"

describe "signs", type: :request do
  before do
    @sign = Fabricate(:sign)
  end

  context "signs#index" do
    it "paginates signs" do
      get signs_path

      expect(response).to be_successful
      assert_select "h2", "weg.li Verkehrszeichen und Symbole"
    end

    it "renders a list of legacy signs as CSV" do
      get signs_path(format: :csv)

      expect(response).to be_successful
      assert CSV.parse(response.body)
    end
  end

  context "signs#show" do
    it "shows a sign" do
      get sign_path(@sign)

      expect(response).to be_successful
      assert_select "h2", "weg.li Verkehrszeichen und Symbole"
    end

    it "handles sign-names with dots" do
      @sign.update!(number: "301.1")
      get sign_path(@sign)

      expect(response).to be_successful
      assert_select "h2", "weg.li Verkehrszeichen und Symbole"
    end

    it "gets a sign as json" do
      get sign_path(@sign, format: :json)

      expect(response).to be_successful
      assert JSON.parse(response.body)
    end

    it "gets a sign as png" do
      @sign.update!(number: "301")
      get sign_path(@sign, format: :png)

      expect(response).to be_successful
      expect(response.content_type).to eql("image/png")
    end
  end
end
