require 'yaml'

require 'payu/version'
require 'payu/pos'
require 'payu/timestamp'
require 'payu/transaction'
require 'payu/response'
require 'payu/signature'
require 'payu/errors'

module Payu
  ENCODINGS = ['ISO', 'WIN', 'UTF']

  @@pos_table = {}

  class SignatureInvalid < StandardError; end
  class PosNotFound < StandardError; end
  class RequestFailed < StandardError; end
  class PosInvalid < StandardError; end
  class TransactionInvalid < StandardError; end

  class << self

    # Loads configuration from specified YAML file creates Pos objects
    def load_pos_from_yaml(filename)
      if File.exist?(filename)
        config = YAML.load_file(filename)
        config.each do |name, config|
          pos = Pos.new(
            :pos_id => config['pos_id'],
            :pos_auth_key => config['pos_auth_key'],
            :key1 => config['key1'],
            :key2 => config['key2'],
            :gateway_url => config['gateway_url'],
            :variant => config['variant'],
            :add_signature => config['add_signature'],
            :test_payment => config['test_payment']
          )
          @@pos_table[name] = pos
        end

        true
      else
        false
      end
    end

    def add_pos(name, pos)
      @@pos_table[name.to_s] = pos
    end

    # Combined accessor, returns Pos object with given pos_id or name
    #
    # @param [String, Integer] name_or_id name or pos_id of Pos
    # @return [Object] the Pos object
    def [](name_or_id)
      get_pos_by_name(name_or_id) || get_pos_by_id(name_or_id) || raise(PosNotFound)
    end

    # Returns Pos object with given name, the same as in payments.yml file
    #
    # @param [String] name name of Pos
    # @return [Object] the Pos object
    def get_pos_by_name(name)
      @@pos_table[name.to_s]
    end

    # Returns Pos object with given pos_id, the same as in payments.yml file
    #
    # @param [Integer] id pos_id of Pos
    # @return [Object] the Pos object
    def get_pos_by_id(pos_id)
      pos_id = pos_id.to_i rescue 0
      @@pos_table.each do |k, v|
        return v if v.pos_id == pos_id
      end
      nil
    end
  end
end

if defined?(Rails)
  require "payu/helpers"

  ActionView::Base.send(:include, Payu::Helpers)
  ActionController::Base.send(:include, Payu::Helpers)
end
