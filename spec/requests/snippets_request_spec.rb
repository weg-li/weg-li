require 'spec_helper'

describe 'snippets', type: :request do
  let(:user) { Fabricate(:user) }
  let(:snippet) { Fabricate(:snippet, user: user) }

  before do
    login(user)
  end

  context "GET :index" do
    it "index works" do
      get snippets_path

      expect(response).to be_ok
    end
  end

  context "GET :new" do
    it "new works" do
      get new_snippet_path

      expect(response).to be_ok
    end
  end

  context "POST :create" do
    let(:params) {
      {
        snippet: {
          name: 'some name',
          content: 'some content',
        }
      }
    }

    it "creates a snippet with given params" do
      expect {
        post snippets_path, params: params
      }.to change { user.snippets.count }.by(1)
    end
  end
end
