class Question < ActiveRecord::Base
  include Workflow

  workflow do
    state :new do
      event :archive, transitions_to: :archived
    end
    state :archived do
      event :restore, transitions_to: :new
    end
  end

  belongs_to :user

  validates :text, presence: true
  validates :name, presence: true
  validates :email, presence: true, format: { with: /([\.A-Za-z0-9_-]+@[\.A-Za-z0-9_-]+\.[A-Za-z]{2,})+/ }

  # Initializes question attributes by user attributes
  # @param user [User, nil] user
  # @return [Question] question itself
  def init_by_user(user)
    return self unless user
    self.user = user
    self.name = user.name
    self.email = user.email
    self
  end
end
