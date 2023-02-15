# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :authenticate_request

  def create
    new_task = Task::Creator.call(current_user, task_params).result
    if new_task.persisted?
      render json: { task: new_task, success: true }, status: 201
    else
      render json: { task: nil, success: false, errors: new_task.errors.full_messages }, status: 422
    end
  end

  def index
    tasks = Task::Selector.call(current_user, filter_params).result
    render json: { tasks: tasks }
  end

  def update
    updated_task = Task::Updator.call(task, task_params).result
    render json: { task: updated_task, success: true } and return if updated_task.errors.blank?
    render json: { task: updated_task, success: false, errors: updated_task.errors.full_messages }, status: 422
  end

  def destroy
    task.destroy
    render json: { success: true }
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, :completed, :due, tags_array: [])
  end

  def filter_params
    params.slice(:tags, :category_id).to_unsafe_h
  end

  def task
    @task ||= current_user.tasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error_messages: [{ task: 'Not Found' }] }
  end
end
