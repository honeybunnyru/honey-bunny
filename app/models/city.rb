class City < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  default_scope -> { order(name: :asc) }
end
