require 'minitest/autorun'
require './vending_machine'

describe VendingMachine do
  before do
    @vending_machine = VendingMachine.new
  end

  describe '#insert' do
    it '10円 を insert すると、0円 が返ること' do
      _(@vending_machine.insert(10)).must_equal 0
    end

    it '50円 を insert すると、0円 が返ること' do
      _(@vending_machine.insert(50)).must_equal 0
    end

    it '100円 を insert すると、0円 が返ること' do
      _(@vending_machine.insert(100)).must_equal 0
    end

    it '500円 を insert すると、0円 が返ること' do
      _(@vending_machine.insert(500)).must_equal 0
    end

    it '1000円 を insert すると、0円 が返ること' do
      _(@vending_machine.insert(1000)).must_equal 0
    end

    it '5000円 を insert すると、5000円 が返ること' do
      _(@vending_machine.insert(5000)).must_equal 5000
    end

    it '想定外のものを insert すると、insert したものが返ること' do
      _(@vending_machine.insert('葉っぱのおかね')).must_equal '葉っぱのおかね'
    end
  end

  describe '#input_amount' do
    it 'insert した金額が返ること' do
      @vending_machine.insert(1000)
      _(@vending_machine.input_amount).must_equal 1000
    end

    it '複数回 insert したとき、その合計金額が返ること' do
      @vending_machine.insert(100)
      @vending_machine.insert(1000)
      _(@vending_machine.input_amount).must_equal 1100
    end
  end

  describe '#refund' do
    it 'insert した合計金額が返ること' do
      @vending_machine.insert(100)
      @vending_machine.insert(1000)
      _(@vending_machine.refund).must_equal 1100
    end

    it 'input_amount が 0 になること' do
      @vending_machine.insert(100)
      @vending_machine.insert(1000)
      @vending_machine.refund
      _(@vending_machine.input_amount).must_equal 0
    end
  end

  describe '#stock_tally' do
    it '初期状態として 120 円のコーラが 5 本入っており、その情報が返ること' do
      _(@vending_machine.stock_tally).must_equal({ 'コーラ' => { price: 120, count: 5 } })
    end
  end

  describe '#test_store' do
    it 'ドリンクを投入できること' do
      _(@vending_machine.store(Cola.new).size).must_equal(6)
    end

    it '投入したドリンクの情報が在庫情報に反映されること' do
      @vending_machine.store(Cola.new)
      _(@vending_machine.stock_tally).must_equal({ 'コーラ' => { price: 120, count: 6 } })
    end
  end

  describe '#buy?' do
    it '投入金額が足りており、かつ在庫がある場合、 true が返ること' do
      @vending_machine.insert(500)
      _(@vending_machine.buy?(:cola)).must_equal(true)
    end

    it '投入金額が足りていない場合、 false が返ること' do
      @vending_machine.insert(100)
      _(@vending_machine.buy?(:cola)).must_equal(false)
    end

    it '在庫がない場合、 false が返ること' do
      @vending_machine.insert(1000)
      5.times { @vending_machine.buy(:cola) }
      _(@vending_machine.buy?(:cola)).must_equal(false)
    end
  end

  describe '#buy' do
    it '投入金額が足りている場合、 購入したドリンクと釣り銭が返ること' do
      @vending_machine.insert(500)
      bought_drink, change = @vending_machine.buy(:cola)
      _(bought_drink).must_be_instance_of(Cola)
      _(change).must_equal(380)
    end

    it '投入金額が足りていない場合、 nil が返ること' do
      @vending_machine.insert(100)
      _(@vending_machine.buy(:cola)).must_be_nil
    end

    it '在庫がない場合、 nil が返ること' do
      @vending_machine.insert(1000)
      5.times { @vending_machine.buy(:cola) }
      _(@vending_machine.buy(:cola)).must_be_nil
    end

    it 'ドリンクを購入した場合、その price と同じ値の分 sales_amount が増えること' do
      @vending_machine.insert(500)
      @vending_machine.buy(:cola)
      _(@vending_machine.sales_amount).must_equal(120)
    end

    it 'ドリンクを購入した場合、その price と同じ値の分 input_amount が減ること' do
      @vending_machine.insert(500)
      @vending_machine.buy(:cola)
      _(@vending_machine.input_amount).must_equal(380)
    end

    it 'ドリンクを購入した場合、在庫の量が減ること' do
      @vending_machine.insert(500)
      @vending_machine.buy(:cola)
      _(@vending_machine.stock_tally['コーラ'][:count]).must_equal(4)
    end

    it 'ドリンクを購入できなかった場合、sales_amount が増えないこと' do
      @vending_machine.insert(100)
      @vending_machine.buy(:cola)
      _(@vending_machine.sales_amount).must_equal(0)
    end

    it 'ドリンクを購入できなかった場合、input_amount が減らないこと' do
      @vending_machine.insert(100)
      @vending_machine.buy(:cola)
      _(@vending_machine.input_amount).must_equal(100)
    end

    it 'ドリンクを購入できなかった場合、在庫が減らないこと' do
      @vending_machine.insert(100)
      @vending_machine.buy(:cola)
      _(@vending_machine.stock_tally['コーラ'][:count]).must_equal(5)
    end
  end

  describe '#sales_amount' do
    it '初期状態では 0 が返ること' do
      _(@vending_machine.sales_amount).must_equal(0)
    end

    it 'ドリンクを購入すると、購入された金額の合計額が返ること' do
      @vending_machine.insert(500)
      @vending_machine.buy(:cola)
      _(@vending_machine.sales_amount).must_equal(120)
      @vending_machine.buy(:cola)
      _(@vending_machine.sales_amount).must_equal(240)
    end
  end
end
