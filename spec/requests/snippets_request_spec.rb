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

  context "GET :edit" do
    it "new works" do
      get edit_snippet_path(snippet)

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

  context "PATCH :create" do
    it "creates a snippet with given params" do
      params = {
        id: snippet.id,
        snippet: {
          name: 'dubbi',
        }
      }
      expect {
        patch snippet_path(snippet.id), params: params
      }.to change { snippet.reload.name }.to('dubbi')
    end
  end

  context "DELETE :destroy" do
    it "creates a snippet with given params" do
      id = snippet.id
      expect {
        delete snippet_path(id)
      }.to change { user.snippets.count }.by(-1)
    end
  end
end
