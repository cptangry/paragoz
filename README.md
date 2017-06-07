# Paragoz

Welcome to Paragöz gem! It is parsing currency
data from Doviz.com and calculate exchange etc.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'paragoz'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install paragoz

## Usage

```ruby
  include Paragoz

  Paragoz.Currencies_ALL # All currencies class
  Paragoz.Currencies_ALL.json_data # All currencies as hash
# You can create a currency without params( Default: 1 USD)
  usd = Paragoz.new_currency
# Also you have choices
  euro = Paragoz.new_currency(code: "eur", amount: 5)

# Paragoz.CURRENCY_CODES for all codes
# You can exchance currenies
  usd.exchance_with(euro, 1) # Second parameter to ignore your currency amount 

# usd.exchance_with(euro) will exchance class amount instance to euro

# Instances:
# for Currencies_All object
    json_data # Returns a hash: {update_date: int, name: string, selling: float, buying: float, change_rate: float}
# for your currency object
  usd = Paragoz.new_currency
  usd.currency_code # Symbol
  usd.currency_update_date # Integer
  usd.currency_name # String
  usd.currency_selling # Float: Selling value
  usd.currency_buying # Float: Buying value
  usd.currency_change_rate # Float: Change rate
# Methods:
# for Paragoz module
  currency = Paragoz.new_ currency # Named Parameters: 'code: "usd"' 'amount: 1' 'data: nil'
# if you dont pass any hash to data then Currencies_All.json_data is default.
# RAW JSON DATA
    Paragoz.RESPONSE.body

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cptangry/paragoz.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
