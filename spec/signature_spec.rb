# encoding: utf-8

require 'spec_helper'

describe 'Signature' do
  before do
    @expected_hash = 'e80b5017098950fc58aad83c8c14978e' # hash for 'abcdef'
  end

  it 'should generate MD5 hash for passed value' do
    Payu::Signature.generate('abcdef').should == @expected_hash
  end

  it 'should concatenate multiple values' do
    Payu::Signature.generate('abc', 'def').should == @expected_hash
    Payu::Signature.generate('ab' ,'cd', 'ef').should == @expected_hash
    Payu::Signature.generate(%w{a b c d e f}).should == @expected_hash

    Payu::Signature.generate('def', 'abc').should_not == @expected_hash
  end

  it 'should skip empty strings' do
    Payu::Signature.generate('abc', '', 'def').should == @expected_hash
  end

  it 'should skip nils' do
    Payu::Signature.generate('abc', nil, 'def').should == @expected_hash
  end

  it 'should do verify signature' do
    lambda do
      Payu::Signature.verify!(@expected_hash, 'abc', 'def')
    end.should_not raise_exception
  end

  it 'should raise exception when signature is not valid' do
    lambda do
      Payu::Signature.verify!(@expected_hash, 'def', 'abc')
    end.should raise_exception(Payu::SignatureInvalid)
  end
end
