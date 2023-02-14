# frozen_string_literal: true

class SubtasksController < ApplicationController
  before_action :authenticate_request

  def create
    new_subtask = task.subtasks.build(subtask_params)
    if new_subtask.save
      render json: { subtask: new_subtask, success: true }, status: 201
    else
      render json: { subtask: nil, success: false, errors: new_subtask.errors.full_messages }, status: 422
    end
  end

  def index
    render json: { subtasks: subtasks }
  end

  def update
    if subtask.update(subtask_params)
      render json: { subtask: subtask, success: true }
    else
      render json: { subtask: subtask, success: false, errors: subtask.errors.full_messages }, status: 422
    end
  end

  def destroy
    subtask.destroy
    render json: { success: true }
  end

  private

  def subtask_params
    params.require(:subtask).permit(:title, :description, :done)
  end

  def subtasks
    task.subtasks
  end

  def task
    @task ||= Task.find(params[:task_id])
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, errors: [{ task: 'Not Found' }] }
  end

  def subtask
    @subtask ||= task.subtasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, errors: [{ subtask: 'Not Found' }] }
  end
end
