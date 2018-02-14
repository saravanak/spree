FactoryBot.define do
  factory :shipment, class: Spree::Shipment do
    tracking 'U10000'
    cost 100.00
    state 'pending'
    order
    stock_location

    after(:create) do |shipment, _evalulator|
      shipment.add_shipping_method(create(:shipping_method), true)
      shipment.order.line_items.group_by(&:variant).each do |variant, line_items|
        is_negative_stock = variant.total_on_hand < 0
        shipment.inventory_units.create(
          order_id: shipment.order_id,
          variant_id: variant.id,
          line_item_id: line_items.first.id,
          quantity: line_items.sum(&:quantity),
          state: is_negative_stock ? 'backordered' : 'on_hand'
        )
      end
    end

    factory :flat_rate_shipping do
      after(:create) { |c| c.shipping_methods.first.calculator = create(:shipping_calculator) }
    end
  end
end
