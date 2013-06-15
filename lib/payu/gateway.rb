# encoding: utf-8

require 'net/http'
require 'net/https'

module Payu
  class Gateway
    attr_reader :encoding, :key1, :key2, :pos_id

    def initialize(options = {})
      @encoding = options[:encoding]
      @key1     = options[:key1]
      @key2     = options[:key2]
      @pos_id   = options[:pos_id]
    end

    def get(session_id)
      send_request("/paygw/#{encoding}/Payment/get/txt", session_id)
    end

    def confirm(session_id)
      send_request("/paygw/#{encoding}/Payment/confirm/txt", session_id)
    end

    def cancel(session_id)
      send_request("/paygw/#{encoding}/Payment/cancel/txt", session_id)
    end

    private
    def send_request(url, session_id)
      data = prepare_data(session_id)
      connection = Net::HTTP.new('www.platnosci.pl', 443)
      connection.use_ssl = true

      http_response = connection.start do |http|
        post = Net::HTTP::Post.new(url)
        post.set_form_data(data)
        http.request(post)
      end

      if http_response.code == '200'
        response = Response.parse(http_response.body)
        verify!(response) if response.status == 'OK'

        return response
      else
        raise RequestFailed
      end
    end

    def prepare_data(session_id)
      ts  = (Time.now.to_f * 1000).to_i
      sig = Signature.generate(pos_id, session_id, ts, key1)

      {
        'pos_id' => pos_id,
        'session_id' => session_id,
        'ts' => ts,
        'sig' => sig
      }
    end

    def verify!(response)
      Signature.verify!(response.trans_sig,
        response.trans_pos_id,
        response.trans_session_id,
        response.trans_order_id,
        response.trans_status,
        response.trans_amount,
        response.trans_desc,
        response.trans_ts,
        key2
      )
    end
  end
end
