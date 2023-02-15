# frozen_string_literal: true

class SubtasksController < ApplicationController
  before_action :authenticate_request

  def create
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
    params.require(:subtask).permit(:title, :description, :completed, :due)
  end

  def subtasks
    task.subtasks
  end

  def new_subtask
    @new_subtask ||= task.subtasks.build(subtask_params)
  end

  def task
    @task ||= current_user.tasks.find(params[:task_id])
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, errors: [{ task: 'Not Found' }] }
  end

  def subtask
    @subtask ||= task.subtasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, errors: [{ subtask: 'Not Found' }] }
  end
end
