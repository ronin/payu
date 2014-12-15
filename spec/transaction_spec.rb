# encoding: utf-8

require 'spec_helper'

describe 'Transaction' do
  before do
    @pos_signed = Payu::Pos.new(
      :pos_id => 1,
      :pos_auth_key => 'abcde',
      :key1 => '3d91f185cacad7c1d830d1472dfaacc5',
      :key2 => 'a747e4b3e49e17459a8a402518d36022'
    )

    @pos_with_gateway = Payu::Pos.new(
      :pos_id => 1,
      :pos_auth_key => 'abcde',
      :gateway_url => 'www.payu.cz',
      :key1 => '3d91f185cacad7c1d830d1472dfaacc5',
      :key2 => 'a747e4b3e49e17459a8a402518d36022'
    )

    @pos_unsigned = Payu::Pos.new(
      :pos_id => 1,
      :pos_auth_key => 'abcde',
      :key1 => '3d91f185cacad7c1d830d1472dfaacc5',
      :key2 => 'a747e4b3e49e17459a8a402518d36022',
      :add_signature => false
    )

    @sms_pos = Payu::Pos.new(
      :pos_id => 1,
      :pos_auth_key => 'abcde',
      :key1 => '3d91f185cacad7c1d830d1472dfaacc5',
      :key2 => 'a747e4b3e49e17459a8a402518d36022',
      :add_signature => true,
      :variant => 'sms'
    )
  end

  it "should raise exception when required attributes are empty" do
    lambda do
      @pos_signed.new_transaction
    end.should raise_exception(Payu::TransactionInvalid)
  end

  it 'should generate session_id when empty' do
    transaction = @pos_signed.new_transaction(
      :amount => 100,
      :desc => 'Description',
      :first_name => 'John',
      :last_name => 'Doe',
      :email => 'john.doe@example.org',
      :client_ip => '127.0.0.1'
    )

    transaction.session_id.should_not be_nil
    transaction.session_id.class.should == Fixnum
  end

  it 'should not overwrite passed session_id' do
    transaction = @pos_signed.new_transaction(
      :session_id => 123,
      :amount => 100,
      :desc => 'Description',
      :first_name => 'John',
      :last_name => 'Doe',
      :email => 'john.doe@example.org',
      :client_ip => '127.0.0.1'
    )

    transaction.session_id.should == 123
  end

  describe "signature" do
    context "should be generated" do
      it do
        transaction = @pos_signed.new_transaction(
            :session_id => '123',
            :amount => 100,
            :desc => 'Description',
            :first_name => 'John',
            :last_name => 'Doe',
            :email => 'john.doe@example.org',
            :client_ip => '127.0.0.1'
        )

        transaction.ts.should_not be_nil
        transaction.ts.class.should == Fixnum

        signature_keys = [1, '123', 'abcde', 100, 'Description', 'John', 'Doe', 'john.doe@example.org', '127.0.0.1', transaction.ts, '3d91f185cacad7c1d830d1472dfaacc5']
        expected_signature = Digest::MD5.hexdigest(signature_keys.join)

        transaction.sig.should == expected_signature
      end

      it 'from all keys' do
        transaction = @pos_signed.new_transaction(
            :pos_auth_key => 'abcde',
            :pay_type => 't',
            :amount => 15000,
            :desc => 'Testowa',
            :desc2 => 'Szczegółowy opis',
            :trsDesc => 'Dodatkowy opis dla banku',
            :order_id => 69,
            :first_name => 'Jan',
            :last_name => 'Kowalski',
            :payback_login => 'jankowalski',
            :street => 'Warszawska',
            :street_hn => '21',
            :street_an => '18',
            :city => 'Szczecin',
            :post_code => '01-259',
            :country => 'PL',
            :email => 'jan.kowalski@example.org',
            :phone => '505-606-100',
            :language => 'pl',
            :client_ip => '192.168.1.1'
        )

        signature_keys = [
            1, 't', transaction.session_id, 'abcde', 15000, 'Testowa',
            'Szczegółowy opis', 'Dodatkowy opis dla banku', 69, 'Jan', 'Kowalski',
            'jankowalski', 'Warszawska', '21', '18', 'Szczecin', '01-259', 'PL',
            'jan.kowalski@example.org', '505-606-100', 'pl', '192.168.1.1',
            transaction.ts, '3d91f185cacad7c1d830d1472dfaacc5'
        ]
        expected_signature = Digest::MD5.hexdigest(signature_keys.join)

        transaction.sig.should == expected_signature
      end
    end

    context "shouldn't be generated" do
      it do
        transaction = @pos_unsigned.new_transaction(
            :session_id => '123',
            :amount => 100,
            :desc => 'Description',
            :first_name => 'John',
            :last_name => 'Doe',
            :email => 'john.doe@example.org',
            :client_ip => '127.0.0.1'
        )
        transaction.sig.should == nil
      end
    end
  end

  it 'should set amount_netto attribute for sms variant' do
    transaction = @sms_pos.new_transaction(
      :session_id => '123',
      :amount => 100,
      :desc => 'Description',
      :first_name => 'John',
      :last_name => 'Doe',
      :email => 'john.doe@example.org',
      :client_ip => '127.0.0.1'
    )

    transaction.amount_netto.should == 100
    transaction.amount.should be_nil
  end

  it 'should generate url for new payment' do
    transaction = @pos_signed.new_transaction(
      :amount => 100,
      :desc => 'Description',
      :first_name => 'John',
      :last_name => 'Doe',
      :email => 'john.doe@example.org',
      :client_ip => '127.0.0.1'
    )
    transaction.new_url.should == 'https://www.platnosci.pl/paygw/UTF/NewPayment'
  end

  it 'should generate url for new payment with specified gateway url' do
    transaction = @pos_signed.new_transaction(
      :amount => 100,
      :desc => 'Description',
      :first_name => 'John',
      :last_name => 'Doe',
      :email => 'john.doe@example.org',
      :gateway_url => 'www.payu.cz',
      :client_ip => '127.0.0.1'
    )
    transaction.new_url.should == 'https://www.payu.cz/paygw/UTF/NewPayment'
  end

  it 'should generate url for new payment wit specified gateway url from POS' do
    transaction = @pos_with_gateway.new_transaction(
      :amount => 100,
      :desc => 'Description',
      :first_name => 'John',
      :last_name => 'Doe',
      :email => 'john.doe@example.org',
      :client_ip => '127.0.0.1'
    )
    transaction.new_url.should == 'https://www.payu.cz/paygw/UTF/NewPayment'
  end

  it 'should generate url for new sms payment' do
    transaction = @sms_pos.new_transaction(
      :amount => 100,
      :desc => 'Description',
      :first_name => 'John',
      :last_name => 'Doe',
      :email => 'john.doe@example.org',
      :client_ip => '127.0.0.1'
    )
    transaction.new_url.should == 'https://www.platnosci.pl/paygw/UTF/NewSMS'
  end
end
