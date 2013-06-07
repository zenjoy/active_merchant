require 'test_helper'
require 'common_data/bit_pay'

class BitPayHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Iframes

  def setup
    @helper = BitPay::Helper.new('order-500','cody@example.com', :amount => 500, :currency => 'USD')
  end

  def test_iframe_url
    @helper.stubs(:ssl_post).returns(stub(:body => CommonData::BitPay.raw_invoice_json))

    assert_equal "https://bitpay.com/invoice/?id=W9GRw1q86WPSUlT1U2cGsCZfXXrUM-KqT9fMFnbC9jo=&view=iframe", @helper.iframe_url
  end

  def test_calling_iframe_multiple_times_doesnt_generate_multiple_urls
    @helper.expects(:ssl_post).returns(stub(:body =>CommonData::BitPay.raw_invoice_json)).once

    @helper.iframe_url
    @helper.iframe_url
  end

  def test_basic_helper_fields
    assert_field 'api_key', 'cody@example.com'

    assert_field 'price', '5.00'
    assert_field 'posData', 'order-500'
  end

  def test_currency_with_no_cents
    @helper = BitPay::Helper.new('order-500', 'cody@example.com', :amount => 500, :currency => 'JPY')
    assert_field 'price', '500.00'
  end

  def test_customer_fields
    @helper.customer :first_name => 'Cody', :last_name => 'Fauser', :email => 'cody@example.com', :phone => '555-1234'
    assert_field 'buyerName', 'Cody Fauser'
    assert_field 'buyerEmail', 'cody@example.com'
    assert_field 'buyerPhone', '555-1234'
  end

  def test_address_mapping
    @helper.billing_address :address1 => '1 My Street',
                            :address2 => 'apt 42',
                            :city => 'Leeds',
                            :state => 'Yorkshire',
                            :zip => 'LS2 7EE',
                            :country  => 'CA'

    assert_field 'buyerAddress1', '1 My Street'
    assert_field 'buyerAddress2', 'apt 42'
    assert_field 'buyerCity', 'Leeds'
    assert_field 'buyerState', 'Yorkshire'
    assert_field 'buyerZip', 'LS2 7EE'
    assert_field 'buyerCountry', 'CA'
  end

  def test_unknown_address_mapping
    @helper.billing_address :farm => 'CA'
    assert_equal 4, @helper.fields.size
  end

  def test_unknown_mapping
    assert_nothing_raised do
      @helper.company_address :address => '500 Dwemthy Fox Road'
    end
  end

  def test_setting_invalid_address_field
    fields = @helper.fields.dup
    @helper.billing_address :street => 'My Street'
    assert_equal fields, @helper.fields
  end
end
