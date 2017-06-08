require_relative "paragoz/version"
require 'json'
require 'net/http'
require 'uri'

module Paragoz
  
  CURRENCY_CODES = ["AUD", "BGN", "BRL", "CAD", "CHF", "CNY", "CZK", "DKK", "GBP",
    "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "JPY", "KRW", "MXN", "MYR", "NOK", "NZD",
    "PHP", "PLN", "RON", "RUB", "SEK", "SGD", "THB", "USD", "ZAR", "EUR", "TRY"]
    
   private class Currency
    attr_reader :currencies_defined, :base, :date, :rates, :costs, :amount
    
    @@currencies_defined = 0
    
    def initialize(code, amount, data = nil)
      data    = data || parse_data(take_response(code.upcase))
      @base   = data["base"]
      @date   = data["date"]
      @rates  = data["rates"]
      @costs  = cost_of_other_currencies
      @amount = amount
      
      @@currencies_defined += 1
    end
     
    private def parse_data(response)
      JSON.parse(response.body) if response.code == '200'
    end
  
    private def take_response(base)
      url = URI.parse("http://api.fixer.io/latest?base=#{base}")
      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Get.new(url.request_uri)
      response = http.request(request)
    end
    
    private def cost_of_other_currencies
      costs = {}
      @rates.each_pair do |k, v|
        costs[k] = 1 / v
      end
      costs
    end
     
     def calculate_cost(currency_code ,calculate_amount = 1.0, info = false)
       cost = @cost[currency_code] * amount
       if amount.is_a?(Float) && amount > 0  && CURRENCY_CODES.include?(currency_code.upcase)
         puts "You need #{cost} #{@base} to buy #{amount} #{currency_code}"
         @cost[currency_code] * amount
       else
         puts "ERROR! You need to give 2 parameters >>  currency_code & calculate_amount"
         puts "Use 'Paragoz::CURRENCY_CODES' for see all defined currency codes."
         puts "Amount has to be an float and greater than 0."
       end
     end
     
     def currency_to_currency(other_currency_object, info = false)
       exchange = @amount * @rates[other_currency_object.base]
       printf("%.2f %s equals to %.4f %s \n", @amount, @base, exchange, other_currency_object.base) if info
       exchange
     end
    
    
    def exchance_to(currency_code, exchance_amount = nil, info = false)
      amount = exchance_amount || self.amount
      exchange = @rates[currency_code.upcase] * amount
      printf("%.2f %s equals to %.4f", amount, @base, exchange) if info
      exchange
    end
    
    def take_rate(currency_code)
      @rates[currency_code.upcase]
    end
     
    def print_costs
      puts "at #{@date}"
      @costs.each_pair do |k, v|
        printf("1.00 %s costs %.4f %s to buy! \n", k, v, @base)
      end
    end
    
    def to_s
      puts "for #{@base} at #{@date}"
      @rates.each_pair do |k, v|
        printf("%.2f %s equals to %.4f %s \n", @amount, @base, v, k)
      end
    end
  end
  
  def self.new_currency(code: "try", amount: 1.0, data: nil)
    if code.is_a?(String) && CURRENCY_CODES.include?(code.upcase) && amount.is_a?(Float) && amount > 0
      Currency.new(code, amount, data)
    else
      puts "ERROR!"
      puts "to define a currency you have to give two named parameters:"
      puts "code: 'currency code as a string' & amount: 'and float greater than 0'"
      puts "Use 'Paragoz::CURRENCY_CODES' for see all defined currency codes."
    end
  end
end
