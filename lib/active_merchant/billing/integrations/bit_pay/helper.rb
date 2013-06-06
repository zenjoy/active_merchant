module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module BitPay
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          # Replace with the real mapping
          mapping :account, 'api_key'
          mapping :amount, 'price'
        
          mapping :order, 'orderID'

          mapping :customer, :name       => 'buyerName',
                             :email      => 'buyerEmail',
                             :phone      => 'buyerPhone'

          mapping :billing_address, :city     => 'buyerCity',
                                    :address1 => 'buyerAddress1',
                                    :address2 => 'buyerAddress2',
                                    :state    => 'buyerState',
                                    :zip      => 'buyerZip',
                                    :country  => 'buyerCountry'

          mapping :notify_url, 'notificationURL'
          mapping :return_url, 'redirectURL'
          mapping :description, 'itemDesc'

          SUPPORTED_COUNTRY_CODES = ['US', 'CA']

          def initialize(order, account, options = {})

          end
        end
      end
    end
  end
end
