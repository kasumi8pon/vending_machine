class VendingMachine
  class NoChangeError < StandardError; end

  INSERTABLE_MONEY = [10, 50, 100, 500, 1000]

  attr_reader :input_amount, :sales_amount, :change_stock

  def initialize
    @input_amount = 0
    @sales_amount = 0
    @change_stock = { 10 => 10, 50 => 10, 100 => 10, 500 => 10, 1000 => 5 }
    @drink_stock = Hash.new { |hash, key| hash[key] = [] }
    5.times { self.store(Cola.new) }
  end

  def insert(money)
    return money unless INSERTABLE_MONEY.include?(money)

    @input_amount += money
    0
  end

  def refund
    refund_money = @input_amount

    rest_input_amount = @input_amount
    refund_change = Hash.new(0)

    [1000, 500, 100, 50, 10].each do |money|
      count = rest_input_amount / money
      if @change_stock[money] < count
        count = @change_stock[money]
      end
      refund_change[money] = count
      rest_input_amount -= count * money
    end

    raise NoChangeError unless rest_input_amount.zero?

    refund_change.each do |money, count|
      @change_stock[money] -= count
    end
    @input_amount = 0
    refund_money
  end

  def store(drink)
    @drink_stock[drink.class] << drink
  end

  def stock_tally
    @drink_stock.each_with_object({}) do |(drink, drinks), result|
      result[drink.name] = { price: drink.price, count: drinks.size }
    end
  end

  def buy?(drink)
    drink_klass = Object.const_get(drink.to_s.capitalize)
    drink_klass.price <= @input_amount && !@drink_stock[drink_klass].empty?
  end

  def buy(drink)
    return unless buy?(drink)

    drink_klass = Object.const_get(drink.to_s.capitalize)
    @sales_amount += drink_klass.price
    @input_amount -= drink_klass.price
    change = refund
    [@drink_stock[drink_klass].shift, change]
  end
end

class Cola
  def self.name
    'コーラ'
  end

  def self.price
    120
  end
end
