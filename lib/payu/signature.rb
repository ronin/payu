# encoding: utf-8

require 'digest'

module Payu
  class SignatureInvalid < StandardError
  end

  class Signature

    # Generates md5 signature for specified values
    def self.generate(*values)
      Digest::MD5.hexdigest(values.join)
    end

    # Verifies signature for specified values
    def self.verify!(expected, *values)
      raise SignatureInvalid if expected != generate(values)
    end
  end
end
