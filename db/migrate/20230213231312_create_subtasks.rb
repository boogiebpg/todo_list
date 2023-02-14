# frozen_string_literal: true

class CreateSubtasks < ActiveRecord::Migration[7.0]
  def change
    create_table :subtasks do |t|
      t.string :title
      t.text :description
      t.datetime :due
      t.boolean :completed, default: false, index: true
      t.references :task

      t.timestamps
    end
  end
end
