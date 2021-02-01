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

  def test_insert_uninsertable_money
    assert_equal 5000, @vending_machine.insert(5000)
  end

  def test_insert_unknown_object
    assert_equal '葉っぱのおかね', @vending_machine.insert('葉っぱのおかね')
  end

  def test_input_amount
    @vending_machine.insert(1000)
    assert_equal 1000, @vending_machine.input_amount
  end

  def test_insert_money_2_times
    @vending_machine.insert(100)
    @vending_machine.insert(1000)
    assert_equal 1100, @vending_machine.input_amount
  end
end
