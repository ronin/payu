# encoding: utf-8

require 'spec_helper'

describe "Payu::Response" do
  @key1 = '3d91f185cacad7c1d830d1472dfaacc5'
  @key2 = 'a747e4b3e49e17459a8a402518d36022'

  it "should parse payment/get response" do
    body = <<-EOF
status:OK
trans_id:7
trans_pos_id:1
trans_session_id:417419
trans_order_id:
trans_amount:200
trans_status:5
trans_pay_type:t
trans_pay_gw_name:pt
trans_desc:Wpłata dla test@test.pl
trans_desc2:
trans_create:2004-08-2310:39:52
trans_init:2004-08-3113:42:43
trans_sent:2004-08-3113:48:13
trans_recv:
trans_cancel:
trans_auth_fraud:0
trans_ts:1094205761232
trans_sig:b6d68525f724a6d69fb1260874924759
EOF

    response = Payu::Response.parse(body)

    response.status.should == 'OK'
    response.trans_id.should == '7'
    response.trans_pos_id.should == '1'
    response.trans_session_id.should == '417419'
    response.trans_order_id.should == ''
    response.trans_amount.should == '200'
    response.trans_status.should == '5'
    response.trans_pay_type.should == 't'
    response.trans_pay_gw_name.should == 'pt'
    response.trans_desc.should == 'Wpłata dla test@test.pl'
    response.trans_desc2.should == ''
    response.trans_create.should == '2004-08-2310:39:52'
    response.trans_init.should == '2004-08-3113:42:43'
    response.trans_sent.should == '2004-08-3113:48:13'
    response.trans_recv.should == ''
    response.trans_cancel.should == ''
    response.trans_auth_fraud.should == '0'
    response.trans_ts.should == '1094205761232'
    response.trans_sig.should == 'b6d68525f724a6d69fb1260874924759'
  end

  it "should parse error response" do
    body = <<-EOF
status: ERROR
error_nr: 103
error_message: Kod błędu: 103
EOF

    response = Payu::Response.parse(body)

    response.status.should == 'ERROR'
    response.error_nr.should == '103'
    response.error_message.should == 'Kod błędu: 103'
  end

  it "should respond to completed?" do
    response = Payu::Response.new(:trans_status => '99')
    response.should be_completed
  end
end
