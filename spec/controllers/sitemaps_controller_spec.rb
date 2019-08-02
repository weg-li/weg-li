require 'spec_helper'

describe SitemapsController do
  it "renders xml" do
    get :show, format: :xml

    expect(response).to be_successful
  end
end
