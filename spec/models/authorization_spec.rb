# frozen_string_literal: true

require 'spec_helper'

describe Authorization do
  let(:authorization) { Fabricate.build(:authorization) }

  context 'validation' do
    it 'is valid' do
      expect(authorization).to be_valid
    end

    it 'does not allow two twitter auths for the same user' do
      user = Fabricate(:user)
      Fabricate(:authorization, user:)
      expect do
        Fabricate(:authorization, user:)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
