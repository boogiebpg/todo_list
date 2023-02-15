# frozen_string_literal: true

class Task::Selector
  prepend SimpleCommand

  attr_accessor :current_user, :tags_param, :category_param

  def initialize(current_user, filter_params)
    @current_user = current_user
    @tags_param = filter_params[:tags]
    @category_param = filter_params[:category_id]
  end

  def call
    Rails.cache.fetch([ :task_selector, current_user, tags_param, category_param ], expires_in: 60.minutes) do
      tasks = Task
        .where(user: current_user)
        .where(category_id: category_param)
      tasks = tasks
        .joins(:tags)
        .where(tags: { name: tags})
        .distinct if tags.any?
      tasks
    end
  end

  private

  def tags
    return [] if tags_param.nil?
    tags_param.split(',')
  end
end
