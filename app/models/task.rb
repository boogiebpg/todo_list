class Task < ApplicationRecord
  validate :title, :description, :done

  
end
