class OrderItem < ActiveRecord::Base
  belongs_to :order, inverse_of: :order_items, polymorphic: true
  belongs_to :item

  monetize :price_cents

  validates :order, presence: true
  validates :item, presence: true
  validates :item_id, uniqueness: { scope: :order_id }
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validate :validate_item_quantity

  before_validation :set_default_values
  after_save :decrease_item_quantity
  before_destroy :increase_item_quantity

  # @return [Float] total price of items
  def total_price

    price * quantity
  end

  def decrease_item_quantity(options = {})
    return true if !options[:force] && order.canceled?
    item.quantity -= quantity - quantity_was.to_i
    item.save
  end

  def increase_item_quantity(options = {})
    return true if !options[:force] && order.canceled?
    item.quantity += quantity
    item.save
  end

  private

    def set_default_values
      if item.discount > 0
        self.price = item.discount
      else
        self.price = item.try(order.send(:item_price_method_name)) if price_cents.nil? || price_cents == 0
      end
    end

    # Validate that requested quantity is ok
    def validate_item_quantity
      return true if item.nil?
      unless item.could_be_ordered?(quantity - quantity_was.to_i) # check only quantities diff
        errors.add(:quantity, :could_not_be_ordered)
      end
    end
end
