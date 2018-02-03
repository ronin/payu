module Payu
  class Timestamp
    def self.generate
      (Time.now.to_f * 1000).to_i
    end
  end
end
