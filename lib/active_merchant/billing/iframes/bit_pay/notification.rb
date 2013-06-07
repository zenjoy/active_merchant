require 'net/http'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Iframes #:nodoc:
      module BitPay
        class Notification < ActiveMerchant::Billing::Iframes::Notification
          def complete?
            ['complete', 'confirmed'].include?(status)
          end

          def item_id
            params['itemCode']
          end

          def transaction_id
            params['id']
          end

          # When was this payment received by the client.
          def received_at
          end

          def payer_email
            params['buyerEmail']
          end

          # the money amount we received in X.2 decimal.
          def gross
            params['price']
          end

          def gross_cents
            (params['price'].to_f * 100.0)
          end

          def currency
            params['currency']
          end

          def received_at
          end

          def order
            params['posData']
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
          def acknowledge
            payload = raw

            response = ssl_get(BitPay.service_url + "/invoice/#{transaction_id}")

            # Replace with the appropriate codes
            raise StandardError.new("Faulty BitPay result: #{response.body}") unless response.code == 200

            parse(response.body)
            true
          end

          def initialize(post, options = {})
            super

            @api_key = options[:credential1]
          end

          private

          # Take the posted data and move the relevant data into a hash
          def parse(post)
            @params = JSON.parse(post)
          end

          def ssl_get(url, options={})
            uri = URI.parse(url)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true

            request = Net::HTTP::Get.new(uri.request_uri)
            request.basic_auth(@api_key, '')
            http.request(request)
          end
        end
      end
    end
  end
end
