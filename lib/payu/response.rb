# encoding: utf-8

module Payu
  class Response < OpenStruct
    PATTERN = /^(\w+):(?:[ ])?(.*)$/

    def self.parse(body)
      temp = body.gsub("\r", "")
      data = temp.scan(PATTERN)

      new(data)
    end

    def completed?
      trans_status.to_i == 99
    end
  end
end
