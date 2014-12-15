# encoding: utf-8

module Payu
  class Transaction
    attr_accessor :pos_id, :pos_auth_key, :pay_type, :session_id, :amount, :amount_netto, :desc,
      :order_id, :desc2, :trsDesc, :first_name, :last_name, :street, :street_hn,
      :street_an, :city, :post_code, :country, :email, :phone, :language, :client_ip,
      :js, :payback_login, :sig, :ts, :key1, :add_signature, :variant, :encoding,
      :gateway_url

    def initialize(options = {})
      options[:session_id] ||= Timestamp.generate

      options.each do |name, value|
        send("#{name.to_s}=", value)
      end

      validate!

      if options[:add_signature]
        self.ts = Timestamp.generate
        self.sig = generate_signature
      end

      if variant == 'sms'
        self.amount_netto = amount
        self.amount = nil
      end
    end

    def new_url
      if variant == 'sms'
        return "https://#{gateway_url}/paygw/#{encoding}/NewSMS"
      else
        return "https://#{gateway_url}/paygw/#{encoding}/NewPayment"
      end
    end

    private
    def generate_signature
      Signature.generate(
        pos_id,
        pay_type,
        session_id,
        pos_auth_key,
        amount,
        desc,
        desc2,
        trsDesc,
        order_id,
        first_name,
        last_name,
        payback_login,
        street,
        street_hn,
        street_an,
        city,
        post_code,
        country,
        email,
        phone,
        language,
        client_ip,
        ts,
        key1
      )
    end

    private
    def validate!
      invalid_attributes = []

      [:pos_id, :pos_auth_key, :session_id, :desc, :first_name, :last_name, :email, :client_ip, :amount].each do |name|
        invalid_attributes << name if attribute_empty?(name)
      end

      if attribute_empty?(:amount)
        invalid_attributes << :amount
      end

      if invalid_attributes.any?
        raise TransactionInvalid.new("Attributes required: #{invalid_attributes.join(', ')}")
      end
    end

    def attribute_empty?(name)
      value = send(name)
      value.nil? || value.respond_to?(:empty?) && value.empty?
    end
  end
end
