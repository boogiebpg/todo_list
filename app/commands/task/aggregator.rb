# frozen_string_literal: true

class Task::Aggregator
  prepend SimpleCommand

  def initialize
    # @current_user = current_user
    # @tags_param = filter_params[:tags]
    # @category_param = filter_params[:category_id]
  end

  def call
    {
      tasks_count_by_user: tasks_count_by_user,
      tasks_count_by_category_and_user: tasks_count_by_category_and_user,
      tags_count: tags_count
    }
  end

  private

  def tasks_count_by_user
    Task
      .joins(:user)
      .group("users.email")
      .count("tasks.id")
  end

  def tasks_count_by_category_and_user
    Task
      .joins(:user)
      .joins("LEFT JOIN categories ON categories.id = tasks.category_id")
      .group("categories.name")
      .group("users.email")
      .count("tasks.id")
  end

  def tags_count
    Task
      .joins(:tags)
      .group("tags.name")
      .count("tasks.id")
  end
end
