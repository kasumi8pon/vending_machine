require 'minitest/autorun'
require './drink'

describe Drink do
  describe '#expired?' do
    it 'expired_on を過ぎていない場合、 false が返ること' do
      @drink = Drink.new('2021/4/1')
      _(@drink.expired?(::Date.new(2021, 1, 1))).must_equal(false)
    end

    it 'expired_on を過ぎている場合、 true が返ること' do
      @drink = Drink.new('2020/12/31')
      _(@drink.expired?(::Date.new(2021, 1, 1))).must_equal(true)
    end
  end
end
