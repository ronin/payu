# encoding: utf-8

require 'spec_helper'

describe 'Payu::Timestamp' do
  it 'should generate timestamp using current time' do
    Time.should_receive(:now)
    Payu::Timestamp.generate
  end
end