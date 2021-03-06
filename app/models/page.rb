class Page < ActiveRecord::Base
  SYSTEM_PAGES = %w(index products company values cosmetics faq)
  WITHOUT_CONTENT = %w(products faq)

  include SuperbPages::Concerns::Models::Page
  include SuperbTextConstructor::Concerns::Models::Blockable

  mount_uploader :cover, PageCoverUploader

  validates :cover, presence: true

  # @return [Boolean] whether this is system page
  def system?
    SYSTEM_PAGES.include?(slug)
  end

  # @return [Boolean] whether this page could be destroyed
  def destroyable?
    !system?
  end

  # @return [Boolean] whether this page has customizable content
  def has_content?
    !WITHOUT_CONTENT.include?(slug)
  end
end
