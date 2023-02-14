# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  let(:user) { create(:user) }

  let(:auth_header) do
    token = AuthenticateUser.call(user.email, user.password).result
    "Bearer #{token}"
  end

  let(:correct_task_params) do
    {
      task: {
        title: "mytitle",
        description: "value",
        due: Time.current + 1.month,
        # user_id: user.id
      }
    }
  end

  let(:incorrect_task_params) do
    {
      task: {
        title: nil,
        description: "value",
        due: Time.current + 1.month,
        # user_id: user.id
      }
    }
  end

  let(:parsed_json_body) do
    JSON.parse(response.body).deep_symbolize_keys
  end

  describe '#create' do
    context 'when create task without auth headers' do
      it 'responds with a correct error' do
        post :create, format: :json, params: correct_task_params
        expect(response.status).to eq(401)
        expect(parsed_json_body[:error]).to eq('Not Authorized')
      end
    end

    context 'when create task with incorrect auth headers' do
      before(:each) do
        request.headers['Authorization'] = 'Bearer incorrect'
      end

      it 'responds with a correct error' do
        post :create, format: :json, params: correct_task_params
        expect(response.status).to eq(401)
        expect(parsed_json_body[:error]).to eq('Not Authorized')
      end
    end

    context 'when create task with incorrect params' do
      before(:each) do
        request.headers['Authorization'] = auth_header
      end

      it 'responds with 422' do
        post :create, format: :json, params: incorrect_task_params
        expect(response.status).to eq(422)
      end

      it 'includes correct errors' do
        post :create, format: :json, params: incorrect_task_params
        expect(parsed_json_body[:errors]).to include("Title can't be blank")
      end
    end

    context 'when create task with correct json params' do
      before(:each) do
        request.headers['Authorization'] = auth_header
      end

      it 'responds with 200' do
        post :create, format: :json, params: correct_task_params
        expect(response.status).to eq(201)
      end

      it 'creates task record with correct values' do
        expect do
          post :create,
               format: :json,
               params: correct_task_params
        end.to change { Task.count }.by(1)
        expect(Task.last.description).to eq(correct_task_params[:task][:description])
      end

      it 'responds with correct data' do
        post :create, format: :json, params: correct_task_params
        expect(response.header['Content-Type']).to include 'application/json'
        expect(parsed_json_body[:task][:description]).to eq(correct_task_params[:task][:description])
      end
    end
  end

  describe '#update' do
    let(:task) { create(:task, user: user) }
    let(:correct_update_params) { correct_task_params.merge(id: task.id) }
    let(:incorrect_update_params) { incorrect_task_params.merge(id: task.id) }

    context 'when update task without auth headers' do
      it 'responds with a correct error' do
        put :update, format: :json, params: correct_update_params
        expect(response.status).to eq(401)
        expect(parsed_json_body[:error]).to eq('Not Authorized')
      end
    end

    context 'when update task with incorrect auth headers' do
      before(:each) do
        request.headers['Authorization'] = 'Bearer incorrect'
      end

      it 'responds with a correct error' do
        put :update, format: :json, params: correct_update_params
        expect(response.status).to eq(401)
        expect(parsed_json_body[:error]).to eq('Not Authorized')
      end
    end

    context 'when update task with incorrect params' do
      before(:each) do
        request.headers['Authorization'] = auth_header
      end

      it 'responds with 422' do
        put :update, format: :json, params: incorrect_update_params
        expect(response.status).to eq(422)
      end

      it 'includes correct errors' do
        put :update, format: :json, params: incorrect_update_params
        expect(parsed_json_body[:errors]).to include("Title can't be blank")
      end
    end

    context 'when update task with correct params' do
      before(:each) do
        request.headers['Authorization'] = auth_header
      end

      it 'responds with 200' do
        put :update, format: :json, params: correct_update_params
        expect(response.status).to eq(200)
      end

      it 'updates task record' do
        expect do
          put :update,
               format: :json,
               params: correct_update_params
        end.to change { Task.count }.by(1)
        expect(Task.last.description).to eq(correct_update_params[:task][:description])
      end

      it 'responds with correct data' do
        put :update, format: :json, params: correct_update_params
        expect(response.header['Content-Type']).to include 'application/json'
        expect(parsed_json_body[:task][:description]).to eq(correct_update_params[:task][:description])
      end
    end
  end

  describe '#destroy' do
    let!(:task) { create(:task, user: user) }

    context 'when destroy task with correct id' do
      before(:each) do
        request.headers['Authorization'] = auth_header
      end

      it 'responds with 200' do
        delete :destroy, params: { id: task.id }
        expect(response.status).to eq(200)
      end

      it 'decreases tasks count' do
        expect do
          delete :destroy, params: { id: task.id }
        end.to change { Task.count }.by(-1)
      end

      it 'responds with correct message' do
        delete :destroy, params: { id: task.id }
        expect(parsed_json_body[:success]).to be_truthy
      end
    end
  end

  describe '#index' do
    let!(:tasks) { create_list(:task, 3, { user: user }) }

    context 'when destroy task with correct auth headers' do
      before(:each) do
        request.headers['Authorization'] = auth_header
      end

      it 'responds with 200' do
        get :index
        expect(response.status).to eq(200)
      end

      it 'responds with tasks and a proper attrs' do
        get :index
        expect(parsed_json_body[:tasks].count).to eq(3)
        expect(parsed_json_body[:tasks].first.keys).to eq(
          [:id, :title, :description, :due, :completed, :created_at, :updated_at, :user_id]
        )
      end
    end
  end
end
