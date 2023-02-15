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
    tasks = Task.where(user: current_user)
    tasks = tasks.where(category_id: category_param)
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
end
