# encoding: utf-8

module Payu
  ERRORS = {
    100 => 'Missing parameter pos_id',
    101 => 'Missing parameter session_id',
    102 => 'Missing parameter ts',
    103 => 'Missing parameter sig',
    104 => 'Missing parameter desc',
    105 => 'Missing parameter client_ip',
    106 => 'Missing parameter first_name',
    107 => 'Missing parameter last_name',
    108 => 'Missing parameter street',
    109 => 'Missing parameter city',
    110 => 'Missing parameter post_code',
    111 => 'Missing parameter amount',
    112 => 'Invalid bank account number',
    113 => 'Missing parameter email',
    114 => 'Missing parameter phone',
    200 => 'Temporary error',
    201 => 'Temporary database error',
    202 => 'POS blocked',
    203 => 'Invalid pay_type value for provided pos_id',
    204 => 'Selected payment method (pay_type value) is temporary unavailable for provided pos_id',
    205 => 'Provided amount is smaller than minimal amount',
    206 => 'Provided amount is larger than maximal amount',
    207 => 'Transaction limit exceeded',
    208 => 'ExpressPayment has not been activated',
    209 => 'Invalid pos_id or pos_auth_key',
    500 => 'Transaction does not exist',
    501 => 'Unauthorized for this transaction',
    502 => 'Transaction already started',
    503 => 'Transaction already authorized',
    504 => 'Transaction already canceled',
    505 => 'Confirm order already sent',
    506 => 'Transaction already confirmed',
    507 => 'Error while returning funds to client',
    599 => 'Invalid transaction status. Please contact PayU support',
    999 => 'Critical error'
  }

  class << self
    def get_error_description(code)
      return ERRORS[code.to_i]
    end
  end
end
