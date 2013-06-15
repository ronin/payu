# encoding: utf-8

require 'digest'

module Payu
  class SignatureInvalid < StandardError
  end

  class Signature
    def self.generate(*params)
      Digest::MD5.hexdigest(params.join)
    end

    def self.verify!(expected, *params)
      raise SignatureInvalid if expected != generate(params)
    end
  end
end
