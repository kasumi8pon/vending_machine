class VendingMachine
  INSERTABLE_MONEY = [10, 50, 100, 500, 1000]

  attr_reader :input_amount, :sales_amount

  def initialize
    @input_amount = 0
    @sales_amount = 0
    @stock = Hash.new { |hash, key| hash[key] = [] }
    5.times { self.store(Cola.new) }
  end

  def insert(money)
    return money unless INSERTABLE_MONEY.include?(money)

    @input_amount += money
    0
  end

  def refund
    refund_money = @input_amount
    @input_amount = 0
    refund_money
  end

  def store(drink)
    @stock[drink.class] << drink
  end

  def stock_tally
    @stock.each_with_object({}) do |(drink, drinks), result|
      result[drink.name] = { price: drink.price, count: drinks.size }
    end
  end

  def buy?(drink)
    drink_klass = Object.const_get(drink.to_s.capitalize)
    drink_klass.price <= @input_amount && !@stock[drink_klass].empty?
  end

  def buy(drink)
    return unless buy?(drink)

    drink_klass = Object.const_get(drink.to_s.capitalize)
    @sales_amount += drink_klass.price
    @stock[drink_klass].shift
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
