# payu [![Gem Version](https://badge.fury.io/rb/payu.png)](http://badge.fury.io/rb/payu) [![Build Status](https://api.travis-ci.org/ronin/payu.png?branch=master)](http://travis-ci.org/ronin/payu) [![Code Climate](https://codeclimate.com/github/ronin/payu.png)](https://codeclimate.com/github/ronin/payu)


Simple library for accepting payments via PayU.

By [Visuality](http://www.visuality.pl).

## Features

* No dependencies on ActiveSupport or any similar libraries, so it should work in any Ruby application or framework
* Simple configuration (multiple points of sale)
* Automatic signature generation and verification
* View helpers for generating payment form and verifying signatures

## Installation

In your Gemfile:

```ruby
gem 'payu'
````

Or, from the command line:

```ruby
gem install payu
```

## Usage

This gem implements only core functionality for integrating with PayU gateway. It is designed to work with any ruby framework or plain ruby application. To integrate it in your app you need to do some work, but it is really simple.

### Create Pos

Your app will interact with PayU via point of sale (Pos). You can create it on PayU website and get its credentials. With these credentials you can create Pos instance:

```ruby
pos = Payu::Pos.new :pos_id => '12345', :pos_auth_key => 'abcdefghijk', :key1 => 'xxxxxxxx', :key2 => 'xxxxxxxx', :add_signature => true
```

You can also load Pos configuration from yaml file. For example config/payu.yml:

```yaml
bank:
  pos_id: 12345
  pos_auth_key: XXX
  key1: XXX
  key2: XXX
  type: default
  add_signature: true

sms:
  pos_id: 56789
  pos_auth_key: XXX
  key1: XXX
  key2: XXX
  type: sms_premium
  add_signature: false
```

Then add new initializer config/initializers/payu.rb:

```ruby
Payu.load_pos_from_yaml(Rails.root.join('config', 'payu.yml'))
```

Now you can access them by name or pos_id:

```ruby
Payu['bank']
Payu[:bank]
Payu[12345]
Payu['56789']
```

### Change gateway url

If you are in different country you can change default gateway url (www.platnosci.pl). Just set gateway_url option in YAML configuration file or pass this option to Pos.new.

```yaml
bank:
  pos_id: 12345
  pos_auth_key: XXX
  key1: XXX
  key2: XXX
  type: default
  add_signature: true
  gateway_url: 'www.payu.cz'
```

```ruby
pos = Payu::Pos.new :pos_id => '12345', :pos_auth_key => 'abcdefghijk', :key1 => 'xxxxxxxx', :key2 => 'xxxxxxxx', :add_signature => true, :gateway_url => 'www.payu.cz'
```

### Create new payment

To create new payment:

```ruby
@transaction = pos.new_transaction(:first_name => 'John', :last_name => 'Doe', :email => 'john.doe@example.org', :client_ip => '1.2.3.4', :amount => 10000, :desc => 'Transaction description')
```

Now you need to build form with this transaction object:

```
<%= form_tag(@transaction.new_url) do %>
  <%= payu_hidden_fields(@transaction) %>
  <%= submit_tag 'Pay' %>
<% end %>
```

### Read payment status

You can check status of any payment:

```ruby
response = pos.get(123456789)

if response.status == 'OK'
  if response.completed?
    # payment completed
  end
end
```

123456789 is a payment session id. It is automatically generated when you create new transaction.

### Confirm payment

By default when somebody sends a payment it is automatically accepted. You can turn it off and confirm every payment:

```ruby
response = pos.confirm(123456789)
```

### Cancel payment

You can cancel payment:

```ruby
response = pos.cancel(123456789)
```

### Handle Payu callbacks

When payment status changes, Payu will send report to your application. You need controller to handle these reports:

```ruby

class PayuController < ApplicationController
  include Payu::Helpers
  skip_before_filter :verify_authenticity_token

  def ok
    # successful redirect
  end

  def error
    # failed redirect
  end

  def report
    payu_verify_params(params)

    response = Payu['main'].get params[:session_id]

    if response.status == 'OK'
      order = Order.find(response.trans_order_id)

      if response.completed? && order.present?
        # mark order as paid
      else
        # payment not completed
      end
    end

    render :text => 'OK'
  end
```

And routes:

```ruby
  match '/payu/ok' => 'payu#ok'
  match '/payu/error' => 'payu#error'
  match '/payu/report' => 'payu#report'
```

Actions ok and error are pages where user is redirected after payment. You need to enter these url on Payu website.

## Copyright

Copyright (c) 2013 Michał Młoźniak. See LICENSE for details.
