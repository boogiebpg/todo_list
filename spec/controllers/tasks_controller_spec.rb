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
        tags_array: [
          "tag1", "tag2"
        ]
      }
    }
  end

  let(:incorrect_task_params) do
    {
      task: {
        title: nil,
        description: "value",
        due: Time.current + 1.month,
        tags_array: [
          "tag1", "tag2"
        ]
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

      it 'responds with 201' do
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
    before(:each) do
      request.headers['Authorization'] = auth_header
    end
    let!(:tasks) { create_list(:task, 3, { user: user }) }

    context 'when request has correct auth headers' do
      it 'responds with 200' do
        get :index
        expect(response.status).to eq(200)
      end

      it 'responds with tasks and a proper attrs' do
        get :index
        expect(parsed_json_body[:tasks].count).to eq(3)
        expect(parsed_json_body[:tasks].first.keys).to eq(
          %i(id title description due completed created_at updated_at user_id category_id)
        )
      end
    end

    context 'when there are tags for filtering' do
      let(:tag1) { create(:tag, name: 'tag1') }
      let(:tag2) { create(:tag, name: 'tag2') }
      before(:each) do
        Task.first.tags << tag1
        Task.second.tags << tag1
        Task.second.tags << tag2
      end

      it 'responds with 200' do
        get :index, params: { tags: 'tag1,tag2' }
        expect(response.status).to eq(200)
      end

      it 'responds with tagged tasks' do
        get :index, params: { tags: 'tag1,tag2' }
        expect(parsed_json_body[:tasks].count).to eq(2)
        expect(
          parsed_json_body[:tasks].map { |task| task[:id] }
        ).to eq(
          [ Task.first.id, Task.second.id ]
        )
      end
    end

    context 'when there is category for filtering' do
      let(:cat) { create(:category, name: 'SomeCategory') }
      let!(:tasks) { create_list(:task, 2, { user: user, category: cat }) }

      it 'responds with 200' do
        get :index, params: { category_id: cat.id }
        expect(response.status).to eq(200)
      end

      it 'responds with categorized tasks' do
        get :index, params: { category_id: cat.id }
        expect(parsed_json_body[:tasks].count).to eq(2)
        expect(
          parsed_json_body[:tasks].map { |task| task[:id] }
        ).to eq(
          Task.last(2).pluck(:id)
        )
      end
    end

    context 'when there are tags and category for filtering' do
      let(:tag1) { create(:tag, name: 'tag1') }
      let(:tag2) { create(:tag, name: 'tag2') }
      let(:cat) { create(:category, name: 'SomeCategory') }
      let!(:tasks) { create_list(:task, 2, { user: user, category: cat }) }
      before(:each) do
        Task.last.tags << tag1
      end

      it 'responds with 200' do
        get :index, params: { tags: 'tag1,tag2', category_id: cat.id }
        expect(response.status).to eq(200)
      end

      it 'responds with tagged tasks' do
        get :index, params: { tags: 'tag1,tag2', category_id: cat.id }
        expect(parsed_json_body[:tasks].count).to eq(1)
        expect(parsed_json_body[:tasks].first[:id]).to eq(Task.last.id)
      end
    end
  end

  describe '#stats' do
    let(:category1) { create(:category, name: "First Category") }
    let(:category2) { create(:category, name: "Second Category") }
    let(:tag1) { create(:tag, name: "First Tag") }
    let(:tag2) { create(:tag, name: "Second Tag") }
    let(:user2) { create(:user) }
    let!(:tasks) { create_list(:task, 3, { user: user, category: category2 }) }
    let!(:other_tasks) { create_list(:task, 3, { user: user2 }) }

    before(:each) do
      create(:task, user: user, category: category1)
      Task.first.tags << tag1
      Task.second.tags << tag1
      Task.last.tags << tag2
    end

    context 'when request has correct auth headers' do
      it 'responds with 200' do
        get :stats
        expect(response.status).to eq(200)
      end

      it 'responds with correct stats' do
        get :stats
        expect(parsed_json_body[:stats].keys).to eq(
          %i(
            tasks_count_by_user
            tasks_count_by_category_and_user
            tags_count
          )
        )
        expect(parsed_json_body[:stats][:tags_count]).to eq(
          { "Second Tag": 1, "First Tag": 2 }
        )
        expect(parsed_json_body[:stats][:tasks_count_by_user][user.email.to_sym]).to eq(4)
        expect(parsed_json_body[:stats][:tasks_count_by_category_and_user].values).to match_array([1,3,3])
      end
    end
  end
end
