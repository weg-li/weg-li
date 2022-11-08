# frozen_string_literal: true

require 'spec_helper'

describe UsersHelper do
  let(:user) { Fabricate.build(:user, name: 'lora', email: 'lora@weg.li') }

  context 'gravatar' do
    it 'can calculate proper gravatar hashes' do
      expect(helper.gravatar(user)).to eql('<img alt="lora" title="lora" class="gravatar" src="https://www.gravatar.com/avatar/c917b16d39003686ac962d9ced92db2d" />')
    end
  end
end
