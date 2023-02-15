# frozen_string_literal: true

class Task::Creator
  prepend SimpleCommand

  attr_accessor :current_user, :task_params, :tags_array

  def initialize(current_user, task_params)
    @current_user = current_user
    @tags_array = task_params.delete(:tags_array)
    @task_params = task_params
  end

  def call
    new_task = current_user.tasks.build(task_params)
    new_task.save
    return new_task unless new_task.persisted?
    add_tags_to_task(new_task)
  end

  private

  def add_tags_to_task(new_task)
    tags_array.each do |tag|
      record = Tag.where(name: tag).first_or_create!
      new_task.tags << record
    end
    new_task
  end
end
