# frozen_string_literal: true

class Task::Selector
  prepend SimpleCommand

  attr_accessor :current_user, :tags_param

  def initialize(current_user, filter_params)
    @current_user = current_user
    @tags_param = filter_params.delete(:tags)
  end

  def call
    tasks = Task.where(user: current_user)
    if tags.any?
      tasks = tasks
        .joins(:tags)
        .where(tags: { name: tags})
        .distinct
    end
    tasks
  end

  private

  def tags
    return [] if tags_param.nil?
    tags_param.split(',')
  end

  # def add_tags_to_task(new_task)
  #   tags_array.each do |tag|
  #     record = Tag.where(name: tag).first_or_create!
  #     new_task.tags << record
  #   end
  #   new_task
  # end
end
