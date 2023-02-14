# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :authenticate_request

  def create
    new_task = current_user.tasks.build(task_params)
    if new_task.save
      render json: { task: new_task, success: true }, status: 201
    else
      render json: { task: nil, success: false, errors: new_task.errors.full_messages }, status: 422
    end
  end

  def index
    render json: { tasks: tasks }
  end

  def update
    if task.update(task_params)
      render json: { task: task, success: true }
    else
      render json: { task: task, success: false, errors: task.errors.full_messages }, status: 422
    end
  end

  def destroy
    task.destroy
    render json: { success: true }
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, :done)
  end

  def tasks
    current_user.tasks
  end

  def task
    @task ||= current_user.tasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error_messages: [{ task: 'Not Found' }] }
  end
end
