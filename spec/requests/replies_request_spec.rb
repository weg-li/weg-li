require 'spec_helper'

describe 'replies', type: :request do
  let(:user) { Fabricate(:user) }
  let(:notice) { Fabricate(:notice, user: user) }
  let(:reply) { Fabricate(:reply, notice: notice) }

  before do
    login(user)
  end

  context "index" do
    it "index works" do
      get replies_path

      expect(response).to be_ok
    end
  end
end
