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

    expect(response.status).to eq('OK')
    expect(response.trans_id).to eq('7')
    expect(response.trans_pos_id).to eq('1')
    expect(response.trans_session_id).to eq('417419')
    expect(response.trans_order_id).to eq('')
    expect(response.trans_amount).to eq('200')
    expect(response.trans_status).to eq('5')
    expect(response.trans_pay_type).to eq('t')
    expect(response.trans_pay_gw_name).to eq('pt')
    expect(response.trans_desc).to eq('Wpłata dla test@test.pl')
    expect(response.trans_desc2).to eq('')
    expect(response.trans_create).to eq('2004-08-2310:39:52')
    expect(response.trans_init).to eq('2004-08-3113:42:43')
    expect(response.trans_sent).to eq('2004-08-3113:48:13')
    expect(response.trans_recv).to eq('')
    expect(response.trans_cancel).to eq('')
    expect(response.trans_auth_fraud).to eq('0')
    expect(response.trans_ts).to eq('1094205761232')
    expect(response.trans_sig).to eq('b6d68525f724a6d69fb1260874924759')
  end

  it "should parse error response" do
    body = <<-EOF
status: ERROR
error_nr: 103
error_message: Kod błędu: 103
EOF

    response = Payu::Response.parse(body)

    expect(response.status).to eq('ERROR')
    expect(response.error_nr).to eq('103')
    expect(response.error_message).to eq('Kod błędu: 103')
  end

  it "should respond to completed?" do
    response = Payu::Response.new(trans_status: '99')
    response.should be_completed
  end
end
