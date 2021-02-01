class VendingMachine
  def insert(money)
    return money unless [10, 50, 100, 500, 1000].include?(money)

    0
  end
end
