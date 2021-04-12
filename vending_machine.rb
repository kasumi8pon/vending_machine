class VendingMachine
  class NoChangeError < StandardError; end

  INSERTABLE_MONEY = [10, 50, 100, 500, 1000]
  STOCK_MONEY = [10, 50, 100, 500, 1000]
  PRIZE_PROBABILITY = 5

  attr_reader :input_amount, :sales_amount, :change_stock

  def initialize
    @input_amount = 0
    @sales_amount = 0
    @change_stock = { 10 => 10, 50 => 10, 100 => 10, 500 => 10, 1000 => 5 }
    @drink_stock = Hash.new { |hash, key| hash[key] = [] }
    5.times { self.store('コーラ', Cola.new) }
    5.times { self.store('レッドブル', Redbull.new) }
    5.times { self.store('水', Water.new) }
    5.times { self.store('ランダム', [Cola.new, DietCola.new, Tea.new].sample) }
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

  def store(name, drink)
    @drink_stock[name] << drink
  end

  def stock_tally
    @drink_stock.each_with_object({}) do |(drink_name, drinks), result|
      next if drinks.size.zero?

      result[drink_name] = { price: drinks.first.class.price, count: drinks.size }
    end
  end

  def buy?(drink_name)
    !@drink_stock[drink_name].empty? && (@drink_stock[drink_name].first.class.price <= @input_amount)
  end

  def buy(drink_name)
    return unless buy?(drink_name)

    price = @drink_stock[drink_name].first.class.price

    begin
      @input_amount -= price
      change = refund
      @sales_amount += price

      output = [@drink_stock[drink_name].shift]

      if get_prize?(drink_name)
        output << @drink_stock[drink_name].shift
      end

      output << change
    rescue NoChangeError
      @input_amount += price
      nil
    end
  end

  def get_prize?(drink_name)
    return false if @drink_stock[drink_name].empty?

    (1..100).to_a.sample <= PRIZE_PROBABILITY
  end

  def buyable_drinks
    @drink_stock.keys.select { |drink_name| buy?(drink_name) }
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

class DietCola
  def self.name
    'ダイエットコーラ'
  end

  def self.price
    120
  end
end

class Tea
  def self.name
    'お茶'
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
