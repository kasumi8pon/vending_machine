require 'minitest/autorun'
require './vending_machine'

class TestVendingMachine < Minitest::Test
  def setup
    @vending_machine = VendingMachine.new
  end

  def test_insert_10_yen_bill
    assert_equal 0, @vending_machine.insert(10)
  end

  def test_insert_50_yen_coin
    assert_equal 0, @vending_machine.insert(50)
  end

  def test_insert_100_yen_coin
    assert_equal 0, @vending_machine.insert(100)
  end

  def test_insert_500_yen_coin
    assert_equal 0, @vending_machine.insert(500)
  end

  def test_insert_1000_yen_coin
    assert_equal 0, @vending_machine.insert(1000)
  end
end
