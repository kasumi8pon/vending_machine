class VendingMachine
  INSERTABLE_MONEY = [10, 50, 100, 500, 1000]

  def insert(money)
    return money unless INSERTABLE_MONEY.include?(money)

    0
  end
end
