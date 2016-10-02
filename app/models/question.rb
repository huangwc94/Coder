class Question < ActiveRecord::Base
  validates :title, presence: true, uniqueness: true
  validates :answer, presence: true
  validates :quest, presence: true
end
