require 'minitest/autorun'
require_relative "test_helper"

require_relative '../lib/paragoz.rb'

describe Paragoz do
  before do
    Paragoz::VERSION.wont_be_nil
    @doviz_usd = Paragoz.new_currency(code: 'usd', amount: 0.50)
    @doviz_try = Paragoz.new_currency
  end
  
  describe 'Döviz usd nesnesi oluştuğunda' do
    it 'şu niteliklere sahiptir' do
      @doviz_usd.data.wont_be_nil
      @doviz_usd.base.must_be_kind_of String
      @doviz_usd.base.length.must_equal 3
      @doviz_usd.date.must_match /^\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01])$/
      @doviz_usd.rates.wont_be_empty
      @doviz_usd.rates.must_be_kind_of Hash
      @doviz_usd.costs.wont_be_empty
      @doviz_usd.costs.must_be_kind_of Hash
      @doviz_usd.amount.must_be :>, 0
    end

    it 'take_rate davranışı her para kodu için float döner' do
      @doviz_usd.rates.each_key do |k|
        @doviz_usd.take_rate(k).must_be_kind_of Numeric
      end
    end

    it 'calculate_cost davranışı her dövizden o para sınıfı ile bir birim alma maliyetini döner' do
      Paragoz::CURRENCY_CODES.each do |i|
        @doviz_usd.calculate_cost(i).must_be_kind_of Numeric unless i == @doviz_usd.base
      end
    end

    it 'currency_to_currency bir döviz diğer döviz nesnesi cinsinden değerini hesaplar' do
      @doviz_usd.currency_to_currency(@doviz_try).must_be_kind_of Numeric
    end

    it 'exchange_to "parametre/nesnenin amount niteliği" kadar kodu belirtilen döviz olarak karşılığını döner' do
      Paragoz::CURRENCY_CODES.each do |i|
        @doviz_usd.exchance_to(i, rand(1..100)).must_be_kind_of Numeric unless i == @doviz_usd.base
      end
    end
  end
end
