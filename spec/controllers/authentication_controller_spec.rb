# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthenticationController, type: :controller do
  let(:correct_user) do
    create(:user)
  end

  let(:json_response) do
    JSON.parse(response.body)
  end

  describe '#authenticate' do
    context 'when authenticate with incorrect credentials' do
      let(:incorrect_payload) do
        { user: { email: 'incorrect@mail.com', password: 'incorrect' } }
      end

      it 'responds with 401 status' do
        post :authenticate, format: :json, params: incorrect_payload
        expect(response.status).to eq(401)
      end

      it 'responds with a correct error message' do
        post :authenticate, format: :json, params: incorrect_payload
        expect(json_response['error']['user_authentication']).to eq('invalid credentials')
      end
    end

    context 'when authenticate with correct credentials' do
      let(:correct_payload) do
        { email: correct_user.email, password: correct_user.password }
      end

      it 'responds with 201 status' do
        post :authenticate, format: :json, params: correct_payload
        expect(response.status).to eq(201)
      end

      it 'responds with a token' do
        post :authenticate, format: :json, params: correct_payload
        expect(json_response['auth_token']).to be
      end
    end
  end
end
