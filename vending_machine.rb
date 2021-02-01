class VendingMachine
  INSERTABLE_MONEY = [10, 50, 100, 500, 1000]

  attr_reader :input_amount

  def initialize
    @input_amount = 0
  end

  def insert(money)
    return money unless INSERTABLE_MONEY.include?(money)

    @input_amount += money
    0
  end
end
