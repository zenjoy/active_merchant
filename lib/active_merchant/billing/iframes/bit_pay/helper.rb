require 'money'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Iframes #:nodoc:
      module BitPay
        class Helper < ActiveMerchant::Billing::Iframes::Helper
          cattr_accessor :iframe_base_url

          self.service_url = 'https://bitpay.com/api'
          self.iframe_base_url = "https://bitpay.com"

          # Replace with the real mapping
          mapping :account, 'api_key'
          mapping :amount, 'price'
          mapping :currency, 'currency'

          mapping :order, 'posData'

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
            super
            @api_key = account
            create_invoice
          end

          def customer(options = {})
            first = options.delete(:first_name)
            last = options.delete(:last_name)
            options[:name] = "#{first} #{last}"
            super options
          end

          def iframe_url
            @iframe_url ||= "#{iframe_base_url}/invoice/?id=#{transaction_id}&view=iframe"
          end

          def transaction_id
            @invoice['id']
          end

          def expires_in
            (@invoice['expirationTime'] - @invoice['currentTime']) / 1000
          end

          private

          def create_invoice
            return if @invoice
            new_invoice_url = "#{service_url}/invoice"
            response = ssl_post(new_invoice_url, :data => @fields.to_json)
            @invoice = JSON.parse(response.body)
          end

          def ssl_post(url, options = {})
            uri = URI.parse(url)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE

            request = Net::HTTP::Post.new(uri.request_uri)
            request.content_type = "application/json"
            request.body = @fields.to_json
            headers.each { |k,v| request[k] = v }

            http.request(request)
          end

          def headers
            {
              "Authorization" => "Basic " + Base64.strict_encode64(@api_key.to_s).strip,
              "User-Agent" => "BitPay v1.0/ActiveMerchant #{ActiveMerchant::VERSION}"
            }
          end
        end
      end
    end
  end
end
