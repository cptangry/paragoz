require 'json'
require 'net/http'
require 'uri'
require 'pp'

module Paragoz

  CURRENCY_CODES = %i{USD EUR GBP CHF CAD RUB AED AUD DKK SEK NOK JPY KWD ZAR
    BHD LYD SAR IQD ILS IRR INR MXN HUF NZD BRL IDR CSK PLN BGN RON CNY ARS ALL
    AZN BAM BYR CLP COP CRC DZD EGP HKD HRK ISK JOD KRW KZT LBP LKR LTL LVL MAD
    MDL MKD MYR OMR PEN PHP PKR QAR RSD SGD SYP THB TWD UAH UYU}

  URL = URI.parse('http://www.doviz.com/api/v1/currencies/all/latest')
  HTTP = Net::HTTP.new(URL.host, URL.port)
  REQUEST = Net::HTTP::Get.new(URL.request_uri)
  RESPONSE = HTTP.request(REQUEST)

  class Currencies
    attr_reader :json_data
    def initialize(*args)
      @json_data = {}
      args.each do |currency|
        @json_data["#{currency["code"]}".to_sym] = {
          update_date: currency["update_date"],
          name:        currency["full_name"],
          selling:     currency["selling"],
          buying:      currency["buying"],
          change_rate: currency["change_rate"]}
      end
    end
  end

    class Currency
      attr_reader :currency_code,    :currency_update_date, :currency_name,
                  :currency_selling, :currency_buying, :currency_change_rate,
                  :amount
      def initialize(code, amount = 1, currencies)
        @currency_code        = code.upcase.to_sym
        @currency_update_date = currencies[code.upcase.to_sym][:update_date]
        @currency_name        = currencies[code.upcase.to_sym][:name]
        @currency_selling     = currencies[code.upcase.to_sym][:selling]
        @currency_buying      = currencies[code.upcase.to_sym][:buying]
        @currency_change_rate = currencies[code.upcase.to_sym][:change_rate]
        @amount = amount
      end

      def buying_value
        @currency_buying * @amount
      end

      def selling_value
        @currency_selling * @amount
      end

      def amount=(value)
        if value.is_a?(Integer) && value > 0
          @amount = value
        else
          puts "Lütfen atamak için 0'dan büyük bir tamsayı tanımlayın!"
        end
      end

      def exchance_with(currency, other_amount = nil)
         (self.currency_buying * (other_amount || self.amount)) / currency.currency_buying
      end
    end

  def self.new_currency(code: "usd", amount: 1, data: nil)
    new_money = nil
    currencies = data || Currencies_All.json_data
    if CURRENCY_CODES.include?(code.upcase.to_sym)
      new_money = Currency.new(code, amount, currencies)
      new_money
    else
      puts      "Hatalı bir para birimi tanımladınız!"
      print "Para birimi kod listesi: #{CURRENCY_CODES}"
    end
  end

  Response_JSON = JSON.parse(RESPONSE.body) if RESPONSE.code == "200"
  Currencies_All = Currencies.new(*Response_JSON)
end

# usd = Paragoz.new_currency(amount: 4)
# euro = Paragoz.new_currency(code: "eur", amount: 5)
#
# puts "1 Dolar  #{usd.exchance_with(euro, 1)} Euro eder!"
# puts "2 Dolar  #{usd.exchance_with(euro, 2)} Euro eder!"
# puts "3 Dolar  #{usd.exchance_with(euro, 3)} Euro eder!"
#
# puts "4 Dolar  #{usd.exchance_with(euro)} Euro eder!" # Creation amount was 4

