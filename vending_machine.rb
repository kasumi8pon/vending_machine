class VendingMachine
  class NoChangeError < StandardError; end

  INSERTABLE_MONEY = [10, 50, 100, 500, 1000]
  STOCK_MONEY = [10, 50, 100, 500, 1000]

  attr_reader :input_amount, :sales_amount, :change_stock

  def initialize
    @input_amount = 0
    @sales_amount = 0
    @change_stock = { 10 => 10, 50 => 10, 100 => 10, 500 => 10, 1000 => 5 }
    @drink_stock = Hash.new { |hash, key| hash[key] = [] }
    5.times { self.store(Cola.new) }
    5.times { self.store(Redbull.new) }
    5.times { self.store(Water.new) }
  end

  def insert(money)
    return money unless INSERTABLE_MONEY.include?(money)

    @input_amount += money
    @change_stock[money] += 1
    puts "購入可能なドリンク: #{buyable_drinks.join('、')}"
    0
  end

  def refund
    change(@input_amount).each do |money, count|
      @change_stock[money] -= count
    end

    refund_money = @input_amount
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

    begin
      drink_klass = Object.const_get(drink.to_s.capitalize)
      @input_amount -= drink_klass.price
      change = refund
      @sales_amount += drink_klass.price
      [@drink_stock[drink_klass].shift, change]
    rescue NoChangeError
      @input_amount += drink_klass.price
      nil
    end
  end

  def buyable_drinks
    @drink_stock.keys.select { |drink| buy?(drink.to_s.downcase.to_sym) }.map(&:name)
  end

  def change(amount)
    refund_change = Hash.new(0)

    STOCK_MONEY.sort.reverse.each do |money|
      count = amount / money
      if @change_stock[money] < count
        count = @change_stock[money]
      end
      refund_change[money] = count
      amount -= count * money
    end

    raise NoChangeError unless amount.zero?

    refund_change
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

class Redbull
  def self.name
    'レッドブル'
  end

  def self.price
    200
  end
end

class Water
  def self.name
    '水'
  end

  def self.price
    100
  end
end
