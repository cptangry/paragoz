require_relative "paragoz/version"
require 'json'
require 'net/http'
require 'uri'

module Paragoz

  CURRENCY_CODES = ["AUD", "BGN", "BRL", "CAD", "CHF", "CNY", "CZK", "DKK", "GBP",
                    "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "JPY", "KRW", "MXN", "MYR", "NOK", "NZD",
                    "PHP", "PLN", "RON", "RUB", "SEK", "SGD", "THB", "USD", "ZAR", "EUR", "TRY"]

  private class Currency
            attr_reader :currencies_defined, :base, :date, :rates, :costs, :amount, :data

            @@currencies_defined = 0

            def initialize(code, amount, data, date)
              @data   = data || parse_data(take_response(code.upcase, date))
              @time_array = @data["date"].split('-').map {|i| i = i.to_i}
              @base   = @data["base"]
              @date   = Time.new(*@time_array)
              @rates  = @data["rates"]
              @costs  = cost_of_other_currencies
              @amount = amount

              @@currencies_defined += 1
            end

            def parse_data(response)
              JSON.parse(response.body) if response.code == '200'
            end

            def take_response(base, date = nil)
              link = define_link(base, date)
              url = URI.parse(link)
              http = Net::HTTP.new(url.host, url.port)
              request = Net::HTTP::Get.new(url.request_uri)
              response = http.request(request)
            end

            def define_link(base, date)
              return "http://api.fixer.io/latest?base=#{base}" if date.nil?
              "http://api.fixer.io/#{date}?base=#{base}"
            end

            private def cost_of_other_currencies
              costs = {}
              @rates.each_pair do |k, v|
                costs[k] = 1 / v
              end
              costs
            end

            def calculate_cost(currency_code ,calculate_amount = 1.0, info = false)
              cost = self.costs[currency_code] * calculate_amount || self.amount
              if amount.is_a?(Float) && amount > 0  && CURRENCY_CODES.include?(currency_code.upcase)
                puts "You need #{cost} #{@base} to buy #{amount} #{currency_code}" if info
                cost
              else
                puts "ERROR! You need to give 2 parameters >>  currency_code & calculate_amount"
                puts "Use 'Paragoz::CURRENCY_CODES' for see all defined currency codes."
                puts "Amount has to be an float and greater than 0."
              end
            end

            def currency_to_currency(other_currency_object, info = false)
              if self.base != other_currency_object.base
                exchange = self.amount * self.rates[other_currency_object.base]
                printf("%.2f %s equals to %.4f %s \n", @amount, @base, exchange, other_currency_object.base) if info
                exchange
              else
                puts "Error! Trying to conver same currency object."
              end
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
              puts "*" * 76
              puts "for #{@base} at #{@date}".upcase.center(76)
              puts "*" * 76
              @rates.each_pair do |k, v|
                puts "-" * 76
                printf("|          %.2f    >>>    %s    >>>    %03.2f    >>>   %s                 | \n", @amount, @base, v, k)
                puts "-" * 76
              end
              puts "-" * 76
            end
          end

  class Comparation

    attr_reader :time_difference, :comparation_rates, :comparation_costs

    def initialize(currency_object, currency_object_to_compare)
      @time_difference = currency_object.date > currency_object_to_compare.date ? "Currency Object's Rates Are Newer" :
                             "Currency Object's Rates Are Older"
      @comparation_rates       = compare_rates(currency_object.rates, currency_object_to_compare.rates)
      @comparation_costs       = compare_costs(currency_object.costs, currency_object_to_compare.costs)
    end

    private def compare_rates(rates, rates_to_cmpr)
              comparation_hash = {}
              rates.each_pair do |k, v|
                comparation_hash[k] =  {difference: v - rates_to_cmpr[k], status: "#{if v > rates_to_cmpr[k]
                                                                                         'incresed'
                                                                                       elsif v == rates_to_cmpr[k]
                                                                                         'same'
                                                                                       else
                                                                                         'decresed'
                                                                                       end}"}
              end
              comparation_hash
    end

            private def compare_costs(costs, costs_to_cmpr)
              comparation_hash = {}
                      costs.each_pair do |k, v|
                        comparation_hash[k] =  {difference: v - costs_to_cmpr[k], status: "#{if v > costs_to_cmpr[k]
                                                                                          'incresed'
                                                                                        elsif v == costs_to_cmpr[k]
                                                                                          'same'
                                                                                        else
                                                                                          'decresed'
                                                                                        end}"}
                      end
                      comparation_hash
            end
    def to_s
      puts "COMPARATION DATA FOR RATES".center(76)
      puts "|__Curency Code___|______Rate Difference:______|______Change Status________|"
      puts "-" * 76
      @comparation_rates.each_pair { |k, v| printf("       %s        |          %+.4f           |        %s           | \n", k, v[:difference], v[:status] )}
      puts "*" * 76
      puts "COMPARATION DATA FOR COSTS".center(76)
      puts "-" * 76
      puts "|___Curency Code__|______Cost Difference:______|______Change Status________|"
      puts "-" * 76
      @comparation_costs.each_pair { |k, v| printf("       %s        |          %+.4f           |        %s           | \n", k, v[:difference], v[:status] )}
      puts "-" * 76
    end
  end


  def self.compare_currencies(currency_object, currency_object_to_compare)
    if currency_object.is_a?(Object) && currency_object_to_compare.is_a?(Object)
      Comparation.new(currency_object, currency_object_to_compare) if currency_object.base == currency_object_to_compare.base
    else
      puts "ERROR! You can use Currency Objets as parameter!"
    end
  end

  def self.new_currency(code: "try", amount: 1.0, data: nil, date: nil)
    if code.is_a?(String) && CURRENCY_CODES.include?(code.upcase) &&
        amount.is_a?(Float) && amount > 0 && date.nil? || date =~ /^\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01])$/
      Currency.new(code, amount, data, date)
    else
      puts "ERROR!"
      puts "to define a currency you have to give at least two named parameters:"
      puts "code: 'currency code as a string' & amount: 'and float greater than 0'"
      puts "Use 'Paragoz::CURRENCY_CODES' for see all defined currency codes."
      puts "date: parameter format 'YYYY-MM-DD'"
      puts "You can use customized data formated as fixer.io JSON"
    end
  end
end

eur1 = Paragoz.new_currency(code: 'eur')
eur2 = Paragoz.new_currency(code: 'eur' ,date: '2016-06-09')
comparation = Paragoz.compare_currencies(eur1, eur2)

puts comparation

puts eur1