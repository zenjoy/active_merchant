require 'net/http'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module BitPay
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          def complete?
            status == 'complete'
          end

          def item_id
            params['itemCode']
          end

          def transaction_id
            params['orderID']
          end

          # When was this payment received by the client.
          def received_at
            params['']
          end

          def payer_email
            params['buyerEmail']
          end

          # the money amount we received in X.2 decimal.
          def gross
            params['price']
          end

          # Was this a test transaction?
          def test?
            false
          end

          def status
            params['status']
          end

          # Acknowledge the transaction to BitPay. This method has to be called after a new
          # apc arrives. BitPay will verify that all the information we received are correct and will return a
          # ok or a fail.
          #
          # Example:
          #
          #   def ipn
          #     notify = BitPayNotification.new(request.raw_post)
          #
          #     if notify.acknowledge
          #       ... process order ... if notify.complete?
          #     else
          #       ... log possible hacking attempt ...
          #     end
          def acknowledge
            payload = raw

            # Replace with the appropriate codes
            raise StandardError.new("Faulty BitPay result: #{response.body}") unless ["AUTHORISED", "DECLINED"].include?(response.body)
            response.body == "AUTHORISED"
          end

          private

          # Take the posted data and move the relevant data into a hash
          def parse(post)
            params = JSON.parse(post)
          end
        end
      end
    end
  end
end
