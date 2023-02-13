# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :authenticate_request

  def create
    if task = Task.create(task_params)
      render json: { task:, success: true }
    else
      render json: { task: nil, success: false, error_messages: task.error_messages }
    end
  end

  def index
    render json: { tasks: }
  end

  def update
    if task.update(task_params)
      render json: { task:, success: true }
    else
      render json: { task:, success: false, error_messages: task.error_messages }
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
    Task.all
  end

  def task
    @task ||= Task.find(params[:id])
  rescue ActiveRecord::NotFound
    render json: { success: false, error_messages: [{ task: 'Not Found' }] }
  end
end
