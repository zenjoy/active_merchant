require 'money'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Iframes #:nodoc:
      module BitPay
        class Helper < ActiveMerchant::Billing::Iframes::Helper
          self.service_url = 'https://bitpay.com/api'
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
            add_amount(options)
          end

          def customer(options = {})
            first = options.delete(:first_name)
            last = options.delete(:last_name)
            options[:name] = "#{first} #{last}"
            super options
          end

          def iframe_url
            @iframe_url ||= "#{iframe_base_url}/invoice/?id=#{invoice_id}&view=iframe"
          end

          private

          def iframe_base_url
            "https://bitpay.com"
          end

          def add_amount(options)
            add_field('price', "%.2f" % Money.new(options[:amount], options[:currency]).to_f)
          end

          def invoice_id
            new_invoice_url = "#{service_url}/invoice"
            response = ssl_post(new_invoice_url, :data => @fields.to_json)
            JSON.parse(response.body)['id']
          end

          def ssl_post(url, options = {})
            uri = URI.parse(url)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true

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
