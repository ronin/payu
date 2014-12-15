# encoding: utf-8

require 'ostruct'
require 'payu/gateway'

module Payu
  class Pos
    TYPES = ['default', 'sms']

    attr_reader :pos_id, :pos_auth_key, :key1, :key2, :type, :encoding,
                :variant, :gateway_url

    # Creates new Pos instance
    # @param [Hash] options options hash
    # @return [Object] Pos object
    def initialize(options)
      @pos_id        = options[:pos_id].to_i
      @pos_auth_key  = options[:pos_auth_key]
      @key1          = options[:key1]
      @key2          = options[:key2]
      @gateway_url   = options[:gateway_url] || 'www.platnosci.pl'
      @variant       = options[:variant] || 'default'
      @encoding      = options[:encoding] || 'UTF'
      @test_payment  = options.fetch(:test_payment, false)
      @add_signature = options.fetch(:add_signature, true)

      validate_options!
    end

    def validate_options!
      raise PosInvalid.new('Missing pos_id parameter') if pos_id.nil? || pos_id == 0
      raise PosInvalid.new('Missing pos_auth_key parameter') if pos_auth_key.nil? || pos_auth_key == ''
      raise PosInvalid.new('Missing key1 parameter') if key1.nil? || key1 == ''
      raise PosInvalid.new('Missing key2 parameter') if key2.nil? || key2 == ''
      raise PosInvalid.new("Invalid variant parameter, expected one of these: #{TYPES.join(', ')}") unless TYPES.include?(variant)
      raise PosInvalid.new("Invalid encoding parameter, expected one of these: #{ENCODINGS.join(', ')}") unless ENCODINGS.include?(encoding)
    end

    # Creates new transaction
    # @param [Hash] options options hash for new transaction
    # @return [Object] Transaction object
    def new_transaction(options = {})
      options = options.dup

      options.merge!({
        :pos_id => @pos_id,
        :pos_auth_key => @pos_auth_key,
        :gateway_url => options[:gateway_url] || @gateway_url,
        :key1 => @key1,
        :encoding => encoding,
        :variant => variant
      })

      if !options.has_key?(:add_signature)
        options[:add_signature] = add_signature?
      end

      if !options.has_key?(:pay_type)
        options[:pay_type] = test_payment? ? 't' : nil
      end

      Transaction.new(options)
    end

    def get(session_id)
      get_gateway.get(session_id)
    end

    def confirm(session_id)
      get_gateway.confirm(session_id)
    end

    def cancel(session_id)
      get_gateway.cancel(session_id)
    end

    def add_signature?
      @add_signature
    end

    private
    def get_gateway
      Gateway.new(
        :encoding    => encoding,
        :key1        => key1,
        :key2        => key2,
        :pos_id      => pos_id,
        :gateway_url => gateway_url
      )
    end

    def test_payment?
      @test_payment && @variant == 'default'
    end
  end
end
