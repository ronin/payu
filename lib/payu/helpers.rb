# encoding: utf-8

module Payu
  module Helpers
    # Generates form fields for specified transaction object
    def payu_hidden_fields(transaction)
      html = ""

      %w(pos_id pos_auth_key pay_type session_id amount amount_netto desc
      order_id desc2 trsDesc first_name last_name street street_hn
      street_an city post_code country email phone language client_ip
      js payback_login sig ts
      ).each do |field|
        value = transaction.send(field)
        html << hidden_field_tag(field, value) unless value.blank?
      end

      html.html_safe
    end

    # Verifies signature of passed parameters from Payu request
    def payu_verify_params(params)
      pos_id = params['pos_id']
      pos = Payu[pos_id]

      Signature.verify!(
        params['sig'],
        params['pos_id'],
        params['session_id'],
        params['ts'],
        pos.key2
      )
    end
  end
end
