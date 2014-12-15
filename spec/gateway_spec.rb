# encoding: utf-8

require 'simplecov'
SimpleCov.start

require 'spec_helper'
require 'webmock/rspec'

describe 'Payu::Gateway' do
  def build_response(options)
    options.map { |key, value| "#{key}:#{value}" }.join("\n")
  end

  before(:all) do
    @gateway = Payu::Gateway.new(
      :encoding => 'UTF', :key1 => '3d91f185cacad7c1d830d1472dfaacc5',
      :key2 => 'a747e4b3e49e17459a8a402518d36022',:pos_id => 1
    )

    @get_response_body = build_response(
      :status => 'OK',
      :trans_id => 7,
      :trans_pos_id => 1,
      :trans_session_id => 417419,
      :trans_amount => 200,
      :trans_status => 5,
      :trans_desc => 'Wpłata dla test@test.pl',
      :trans_ts => '1094205761232',
      :trans_sig => 'd06d215fa021e68f1cd82f2951a1134b'
    )

    @forged_get_response_body = build_response(
      :status => 'OK',
      :trans_id => 7,
      :trans_pos_id => 1,
      :trans_session_id => 417419,
      :trans_amount => 200,
      :trans_status => 5,
      :trans_desc => 'Wpłata dla test@test.pl',
      :trans_ts => '1094205761232',
      :trans_sig => 'x06d215fa021e68f1cd82f2951a1134b'
    )

    @modify_response_body = build_response(
      :status => 'OK',
      :trans_id => 7,
      :trans_pos_id => 1,
      :trans_session_id => 417419,
      :trans_ts => '1094205761232',
      :trans_sig => '72e5062fecea369a32152a302f6089e4'
    )

    @forged_modify_response_body = build_response(
      :status => 'OK',
      :trans_id => 7,
      :trans_pos_id => 1,
      :trans_session_id => 417419,
      :trans_ts => '1094205761232',
      :trans_sig => 'x2e5062fecea369a32152a302f6089e4'
    )
  end

  it 'should send request to platnosci.pl endpoint and return Response object' do
    stub_request(:post, 'https://www.platnosci.pl/paygw/UTF/Payment/get/txt').to_return(:body => @get_response_body, :status => 200)
    @gateway.get(417419).should be_a(Payu::Response)

    stub_request(:post, 'https://www.platnosci.pl/paygw/UTF/Payment/confirm/txt').to_return(:body => @modify_response_body, :status => 200)
    @gateway.confirm(417419).should be_a(Payu::Response)

    stub_request(:post, 'https://www.platnosci.pl/paygw/UTF/Payment/cancel/txt').to_return(:body => @modify_response_body, :status => 200)
    @gateway.cancel(417419).should be_a(Payu::Response)
  end

  it 'should send request to payu.cz endpoint and return Response object' do
    @gateway = Payu::Gateway.new(
      :encoding => 'UTF', :key1 => '3d91f185cacad7c1d830d1472dfaacc5',
      :key2 => 'a747e4b3e49e17459a8a402518d36022',:pos_id => 1,
      :gateway_url => 'www.payu.cz'
    )

    stub_request(:post, 'https://www.payu.cz/paygw/UTF/Payment/get/txt').to_return(:body => @get_response_body, :status => 200)
    @gateway.get(417419).should be_a(Payu::Response)

    stub_request(:post, 'https://www.payu.cz/paygw/UTF/Payment/confirm/txt').to_return(:body => @modify_response_body, :status => 200)
    @gateway.confirm(417419).should be_a(Payu::Response)

    stub_request(:post, 'https://www.payu.cz/paygw/UTF/Payment/cancel/txt').to_return(:body => @modify_response_body, :status => 200)
    @gateway.cancel(417419).should be_a(Payu::Response)
  end

  it 'should raise exception on failed connection' do
    stub_request(:post, 'https://www.platnosci.pl/paygw/UTF/Payment/get/txt').to_return(:status => 500)
    lambda { @gateway.get(1) }.should raise_exception(Payu::RequestFailed)

    stub_request(:post, 'https://www.platnosci.pl/paygw/UTF/Payment/confirm/txt').to_return(:status => 500)
    lambda { @gateway.confirm(1) }.should raise_exception(Payu::RequestFailed)

    stub_request(:post, 'https://www.platnosci.pl/paygw/UTF/Payment/cancel/txt').to_return(:status => 500)
    lambda { @gateway.cancel(1) }.should raise_exception(Payu::RequestFailed)
  end

  it 'should validate response signature' do
    stub_request(:post, 'https://www.platnosci.pl/paygw/UTF/Payment/get/txt').to_return(:body => @forged_get_response_body, :status => 200)
    lambda { @gateway.get(417419) }.should raise_exception(Payu::SignatureInvalid)

    stub_request(:post, 'https://www.platnosci.pl/paygw/UTF/Payment/confirm/txt').to_return(:body => @forged_modify_response_body, :status => 200)
    lambda { @gateway.confirm(417419) }.should raise_exception(Payu::SignatureInvalid)

    stub_request(:post, 'https://www.platnosci.pl/paygw/UTF/Payment/cancel/txt').to_return(:body => @forged_modify_response_body, :status => 200)
    lambda { @gateway.cancel(417419) }.should raise_exception(Payu::SignatureInvalid)
  end
end
