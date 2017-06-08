# Paragoz

Welcome to Paragoz gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/paragoz`. To experiment with that code, run `bin/console` for an interactive prompt.

It will parse currency data from fixer.io currency api JSON and calculate exchange rate, cost etc. for you.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'paragoz'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paragoz

## Usage

```ruby
# To define a usd variable refers to 1 USD object
# Paragoz.new_currency(code: 'usd')
# there is 3 named parameters:
# code: String(default 'try') amount: Float(default: 1.0) data: JSON(default: nil)
# you can use customized json formatted as on http://api.fixer.io/latest?base=USD
# (Also you can pick any currency code after '=' sign when visiting link.) 
usd = Paragoz.new_currency(code: 'usd', amount: 15.0)
usd_other = Paragoz.new_currency(code: 'usd', amount: 5.0) # 5 USD object

# To define a euro variables refers to 50 EURO object
euro = Paragoz.new_currency(code: 'eur', amount: 50.0)
euro_other = Paragoz.new_currency(code: 'eur', amount: 2.5) # 2.5 EURO object


tr = Paragoz.new_currency # Returns Currency Object as 1 TRY
tr_other = Paragoz.new_currency(amount: 750.0) # 750 TRY object
# To see all rates in formatted view
# customized to_s
puts usd
puts euro
puts tr

# To see cost of buying a foreign curreny
# currency_object.print_costs
usd.print_costs
euro.print_costs
tr.print_costs

# You can calculate cost of buying a spesific amount of a specific foreign currency
# 3 parameters: currency_code & calculate_amount (default: 1.0)
# 3rd true for extra info
tr.calculate_amount('usd', 120.0)

# To return a spesific change rate as a number give currency code as a parameter
# To see all currency codes: Paragoz::CURRENCY_CODES will return an array
tr.take_rate('aud')
euro.take_rate('jpy')
usd.take_rate('sek')

# To exchange a currency object to another currency object
# you can give second parameter as true to see more info
sell = tr_other.currency_to_currency(usd)
buy = usd_other.currency_to_currency(euro_other)
test = buy = usd_other.currency_to_currency(euro, true)

```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cptanry/paragoz.
Your questions are welcome at: caglar.gokhan@gmail.com


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

