# encoding: utf-8

module Payu
  class Response < OpenStruct
    PATTERN = /^(\w+):(?:[ ])?(.*)$/

    # Parses text response from Payu gateway
    def self.parse(body)
      temp = body.gsub("\r", "")
      data = temp.scan(PATTERN)

      data_hash = {}
      data.each do |element|
        data_hash[element[0]] = element[1]
      end

      new(data_hash)
    end

    # Checks if transaction was completed (payment received)
    def completed?
      trans_status.to_i == 99
    end
  end
end
