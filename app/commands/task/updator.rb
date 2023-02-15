# frozen_string_literal: true

class Task::Updator
  prepend SimpleCommand

  attr_accessor :task, :task_params, :tags_array

  def initialize(task, task_params)
    @task = task
    @tags_array = task_params.delete(:tags_array)
    @task_params = task_params
  end

  def call
    task.update(task_params)
    return task if task.errors.full_messages.any?
    update_tags_for_task(task)
  end

  private

  def update_tags_for_task(task)
    task.taggings.delete_all
    tags_array.each do |tag|
      record = Tag.where(name: tag).first_or_create!
      task.tags << record
    end
    task
  end
end
