# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubtasksController, type: :controller do
  let(:user) { create(:user) }
  let(:task) { create(:task) }

  let(:auth_header) do
    token = AuthenticateUser.call(user.email, user.password).result
    "Bearer #{token}"
  end

  let(:correct_subtask_params) do
    {
      subtask: {
        title: "mytitle",
        description: "value",
        due: Time.current + 1.month
      },
      task_id: task.id
    }
  end

  let(:incorrect_subtask_params) do
    {
      subtask: {
        title: nil,
        description: "value",
        due: Time.current + 1.month
      }
    }
  end

  let(:parsed_json_body) do
    JSON.parse(response.body).deep_symbolize_keys
  end

  describe '#create' do
    let(:correct_params) { correct_subtask_params.merge(task_id: task.id) }
    let(:incorrect_params) { incorrect_subtask_params.merge(task_id: task.id) }
    context 'when create task without auth headers' do
      it 'responds with a correct error' do
        post :create, format: :json, params: correct_params
        expect(response.status).to eq(401)
        expect(parsed_json_body[:error]).to eq('Not Authorized')
      end
    end

    context 'when create task with incorrect auth headers' do
      before(:each) do
        request.headers['Authorization'] = 'Bearer incorrect'
      end

      it 'responds with a correct error' do
        post :create, format: :json, params: correct_params
        expect(response.status).to eq(401)
        expect(parsed_json_body[:error]).to eq('Not Authorized')
      end
    end

    context 'when create task with incorrect params' do
      before(:each) do
        request.headers['Authorization'] = auth_header
      end

      it 'responds with 422' do
        post :create, format: :json, params: incorrect_params
        expect(response.status).to eq(422)
      end

      it 'includes correct errors' do
        post :create, format: :json, params: incorrect_params
        expect(parsed_json_body[:errors]).to include("Title can't be blank")
      end
    end

    context 'when create task with correct json params' do
      before(:each) do
        request.headers['Authorization'] = auth_header
      end

      it 'responds with 200' do
        post :create, format: :json, params: correct_params
        expect(response.status).to eq(201)
      end

      it 'creates task record with correct values' do
        expect do
          post :create,
               format: :json,
               params: correct_params
        end.to change { Subtask.count }.by(1)
        expect(Subtask.last.description).to eq(correct_params[:subtask][:description])
      end

      it 'responds with correct data' do
        post :create, format: :json, params: correct_params
        expect(response.header['Content-Type']).to include 'application/json'
        expect(parsed_json_body[:subtask][:description]).to eq(correct_params[:subtask][:description])
      end
    end
  end

  describe '#update' do
    let(:subtask) { create(:subtask, task: task) }
    let(:correct_update_params) { correct_subtask_params.merge(id: subtask.id, task_id: task.id) }
    let(:incorrect_update_params) { incorrect_subtask_params.merge(id: subtask.id, task_id: task.id) }

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
        end.to change { Subtask.count }.by(1)
        expect(Subtask.last.description).to eq(correct_update_params[:subtask][:description])
      end

      it 'responds with correct data' do
        put :update, format: :json, params: correct_update_params
        expect(response.header['Content-Type']).to include 'application/json'
        expect(parsed_json_body[:subtask][:description]).to eq(correct_update_params[:subtask][:description])
      end
    end
  end

  describe '#destroy' do
    let!(:subtask) { create(:subtask, task: task) }

    context 'when destroy task with correct id' do
      before(:each) do
        request.headers['Authorization'] = auth_header
      end

      it 'responds with 200' do
        delete :destroy, params: { task_id: task.id, id: subtask.id }
        expect(response.status).to eq(200)
      end

      it 'decreases tasks count' do
        expect do
          delete :destroy, params: { task_id: task.id, id: subtask.id }
        end.to change { Subtask.count }.by(-1)
      end

      it 'responds with correct message' do
        delete :destroy, params: { task_id: task.id, id: subtask.id }
        expect(parsed_json_body[:success]).to be_truthy
      end
    end
  end

  describe '#index' do
    let!(:subtasks) { create_list(:subtask, 3, { task: task }) }

    context 'when destroy task with correct auth headers' do
      before(:each) do
        request.headers['Authorization'] = auth_header
      end

      it 'responds with 200' do
        get :index, params: { task_id: task.id }
        expect(response.status).to eq(200)
      end

      it 'responds with tasks and a proper attrs' do
        get :index, params: { task_id: task.id }
        expect(parsed_json_body[:subtasks].count).to eq(3)
        expect(parsed_json_body[:subtasks].first.keys).to eq(
          [:id, :title, :description, :due, :completed, :task_id, :created_at, :updated_at]
        )
      end
    end
  end
end
