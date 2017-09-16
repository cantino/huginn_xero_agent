require 'xero_gateway'

module Agents
  class XeroAgent < Agent
    cannot_be_scheduled!

    gem_dependency_check { defined?(XeroGateway) }

    description <<-MD
      Create Invoices in Xero based on incoming Events.

      See [this Agent's GitHub page](https://github.com/cantino/huginn_xero_agent) for instructions on setting up this Agent to access your Xero data.

      All options support [Liquid templating](https://github.com/huginn/huginn/wiki/Formatting-Events-using-Liquid).

      Options

        * `expected_receive_period_in_days` - How often you expect data to be received by this Agent from other Agents.
        * `due_in_days` - The number of days from now when the invoice is due.
        * The options `contact_name`, `contact_phone_number`, `contact_email`, `contact_address_line_1`, `contact_address_line_2`, `contact_address_city`, `contact_address_region`, `contact_address_country`, and `contact_address_post_code` allow setting details for a new contact.
        * You can set an `item_path` if you'd like to create multiple invoices, one per record at that [JSONPath](http://goessner.net/articles/JsonPath/).
        * The options `item_description`, `item_account_code`, and `item_amount` allow configuring of invoice details and can contain [Liquid templating](https://github.com/huginn/huginn/wiki/Formatting-Events-using-Liquid), allowing you to make them dynamic based on Event input.
    MD

    def default_options
      {
        due_in_days: 14,
        contact_name: '{{name}}',
        contact_phone_number: '{{phone}}',
        contact_email: '{{email}}',
        item_path: 'items',
        item_description: 'Widget',
        item_account_code: '123',
        item_amount: 20,
        expected_receive_period_in_days: 10
      }
    end

    def working?
      last_receive_at && last_receive_at > options['expected_receive_period_in_days'].to_i.days.ago && !recent_error_logs?
    end

    def validate_options
      errors.add(:base, "due_in_days must be a number") if options['due_in_days'].present? && options['due_in_days'].to_s !~ /\A\d+\z/
      errors.add(:base, "item_description and item_amount are required") unless options['item_description'].present? && options['item_amount'].present?
      errors.add(:base, "expected_receive_period_in_days is required") unless options['expected_receive_period_in_days'].present?
    end

    def gateway
      @gateway ||= XeroGateway::PrivateApp.new(ENV['XERO_CONSUMER_KEY'], ENV['XERO_CONSUMER_SECRET'], ENV['XERO_PRIVATE_KEY_PATH'])
    end

    def receive(incoming_events)
      incoming_events.each do |event|
        invoice = create_invoice(event)
        create_event payload: { id: invoice.invoice_id }
      end
    end

    def create_invoice(event)
      interpolate_with(event.payload) do
        invoice = gateway.build_invoice({
          invoice_type: "ACCREC",
          due_date: (interpolated['due_in_days'].presence || 14).to_i.days.from_now
        })
        invoice.contact.name = interpolated['contact_name'].presence
        invoice.contact.phone.number = interpolated['contact_phone_number'].presence
        invoice.contact.email = interpolated['contact_email'].presence
        invoice.contact.address.line_1 = interpolated['contact_address_line_1'].presence
        invoice.contact.address.line_2 = interpolated['contact_address_line_2'].presence
        invoice.contact.address.city = interpolated['contact_address_city'].presence
        invoice.contact.address.region = interpolated['contact_address_region'].presence
        invoice.contact.address.country = interpolated['contact_address_country'].presence
        invoice.contact.address.post_code = interpolated['contact_address_post_code'].presence

        [Utils.value_at(event.payload, interpolated['item_path'].presence || '.') || {}].flatten.each do |item|
          line_item = XeroGateway::LineItem.new(
            :description => interpolated(item)['item_description'],
            :account_code => interpolated(item)['item_account_code'].presence,
            :unit_amount => interpolated(item)['item_amount']
          )
          invoice.line_items << line_item
        end

        invoice.create
        invoice
      end
    end
  end
end
