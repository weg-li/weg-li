# frozen_string_literal: true

require "spec_helper"

# Screen readers need a text alternative for every button, link, image and form field.
describe "accessibility", type: :request do
  let(:user) { Fabricate(:user) }

  def named?(element)
    element.text.strip.present? ||
      element["aria-label"].present? ||
      element["title"].present? ||
      element.at_css("img[alt]:not([alt=''])").present?
  end

  def labelled?(doc, field)
    field["aria-label"].present? ||
      (field["id"].present? && doc.at_css("label[for='#{field['id']}']").present?) ||
      field.ancestors("label").any? { |label| label.text.strip.present? }
  end

  def problems(html)
    doc = Nokogiri::HTML(html)
    fields = doc.css("input, select, textarea").reject { |field| %w[hidden submit button image].include?(field["type"]) }

    [
      *doc.css("button, a[role=button]").reject { |element| named?(element) }.map { |element| "button without name: #{element.to_html.truncate(100)}" },
      *doc.css("a[href]").reject { |element| named?(element) }.map { |element| "link without name: #{element.to_html.truncate(100)}" },
      *doc.css("img:not([alt])").map { |element| "image without alt: #{element.to_html.truncate(100)}" },
      *fields.reject { |field| labelled?(doc, field) }.map { |field| "field without label: #{field.to_html.truncate(100)}" },
    ]
  end

  context "public pages" do
    {
      root: -> { root_path },
      imprint: -> { imprint_path },
      donate: -> { donate_path },
      generator: -> { generator_path },
      violation: -> { violation_path },
      charges: -> { charges_path },
      brands: -> { brands_path },
      signs: -> { signs_path },
      plates: -> { plates_path },
      districts: -> { districts_path },
    }.each do |name, path|
      it "#{name} has names for buttons, links, images and fields" do
        get instance_exec(&path)

        expect(response).to be_successful
        expect(problems(response.body)).to be_empty
      end
    end

    it "labels the navigation toggle" do
      get root_path

      assert_select("button.navbar-toggle[aria-label][aria-controls=navbar-main]")
    end
  end

  context "signed in" do
    before do
      login(user)
    end

    it "notices has names for buttons, links, images and fields" do
      notice = Fabricate.create(:notice, user:)

      get notices_path

      expect(response).to be_successful
      assert_select("img.index-photo[alt=?]", "Beweisfoto #{notice.registration}")
      expect(problems(response.body)).to be_empty
    end

    it "bulk_uploads has names for buttons, links, images and fields" do
      Fabricate.create(:bulk_upload, user:)

      get bulk_uploads_path

      expect(response).to be_successful
      expect(problems(response.body)).to be_empty
    end

    it "bulk_upload has names for buttons, links, images and fields" do
      bulk_upload = Fabricate.create(:bulk_upload, user:)
      Fabricate.create(:notice, user:, bulk_upload:)

      get bulk_upload_path(bulk_upload)

      expect(response).to be_successful
      expect(problems(response.body)).to be_empty
    end

    it "snippets has names for buttons, links, images and fields" do
      Fabricate.create(:snippet, user:)

      get snippets_path

      expect(response).to be_successful
      expect(problems(response.body)).to be_empty
    end

    it "blueprints has names for buttons, links, images and fields" do
      Fabricate.create(:blueprint, user:)

      get blueprints_path

      expect(response).to be_successful
      expect(problems(response.body)).to be_empty
    end

    it "replies has names for buttons, links, images and fields" do
      get replies_path

      expect(response).to be_successful
      expect(problems(response.body)).to be_empty
    end

    it "the profile has names for buttons, links, images and fields" do
      get user_path

      expect(response).to be_successful
      expect(problems(response.body)).to be_empty
    end

    it "the profile form has names for buttons, links, images and fields" do
      get edit_user_path

      expect(response).to be_successful
      expect(problems(response.body)).to be_empty
    end

    it "names the sort and search controls on notices" do
      Fabricate.create(:notice, user:)

      get notices_path

      assert_select("button[aria-label=Suche]")
      assert_select("input[name='search[term]'][aria-label=Suche]")
      assert_select("a[aria-label='Nach Kennzeichen aufsteigend sortieren']")
    end
  end
end
