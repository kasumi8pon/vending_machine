require 'minitest/autorun'
require './vending_machine'
require 'stringio'

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

    it 'お金を insert すると、購入可能なドリンクのリストが返ること' do
      _ { @vending_machine.insert(100) }.must_output "購入可能なドリンク: 水\n"
    end

    it 'insert したお金が、釣り銭ストックになること' do
      _(@vending_machine.change_stock[10]).must_equal 10
      @vending_machine.insert(10)
      _(@vending_machine.change_stock[10]).must_equal 11
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
    it 'refund すると、釣り銭が減ること' do
      @vending_machine.insert(1000)
      _(@vending_machine.change_stock[1000]).must_equal 6
      @vending_machine.refund
      _(@vending_machine.change_stock[1000]).must_equal 5
    end
  end

  describe '#change' do
    it '引数の金額を釣り銭とした場合の組み合わせが返ること' do
      _(@vending_machine.change(380)).must_equal({ 1000 => 0, 500 => 0, 100 => 3, 50 => 1, 10 => 3 })
    end

    it 'ある種類の釣り銭が足りないとき、それより小額の釣り銭があればその釣り銭を利用した組み合わせが返ること' do
      _(@vending_machine.change(380)).must_equal({ 1000 => 0, 500 => 0, 100 => 3, 50 => 1, 10 => 3 })
    end

    it '釣り銭が足りないとき、エラーが起きること' do
      _ { @vending_machine.change(20000) }.must_raise VendingMachine::NoChangeError
    end
  end

  describe '#stock_tally' do
    it '初期状態として 120 円のコーラ、200 円のレッドブル、100 円の水が 5 本、120 円のランダムドリンクが 5 本入っており、その情報が返ること' do
      _(@vending_machine.stock_tally).must_equal(
        {
          'コーラ' => { price: 120, count: 5 },
          'レッドブル' => { price: 200, count: 5 },
          '水' => { price: 100, count: 5 },
          'ランダム' => { price: 120, count: 5 }
        }
      )
    end
  end

  describe '#test_store' do
    it 'ドリンクを投入できること' do
      _(@vending_machine.store('コーラ', Cola.new).size).must_equal(6)
    end

    it '投入したドリンクの情報が在庫情報に反映されること' do
      @vending_machine.store('コーラ', Cola.new)
      _(@vending_machine.stock_tally).must_equal(
        {
          'コーラ' => { price: 120, count: 6 },
          'レッドブル' => { price: 200, count: 5 },
          '水' => { price: 100, count: 5 },
          'ランダム' => { price: 120, count: 5 }
        }
      )
    end
  end

  describe '#buy?' do
    it '投入金額が足りており、かつ在庫がある場合、 true が返ること' do
      @vending_machine.insert(500)
      _(@vending_machine.buy?('コーラ')).must_equal(true)
    end

    it '投入金額が足りていない場合、 false が返ること' do
      @vending_machine.insert(100)
      _(@vending_machine.buy?('コーラ')).must_equal(false)
    end

    it '在庫がない場合、 false が返ること' do
      5.times do
        @vending_machine.insert(100)
        @vending_machine.insert(20)
        @vending_machine.insert(20)
        @vending_machine.buy('コーラ')
      end
      _(@vending_machine.buy?('コーラ')).must_equal(false)
    end
  end

  describe '#buy' do
    it '投入金額が足りている場合、 購入したドリンクと釣り銭が返ること' do
      @vending_machine.insert(500)
      bought_drink, change = @vending_machine.buy('コーラ')
      _(bought_drink).must_be_instance_of(Cola)
      _(change).must_equal(380)
    end

    it '投入金額が足りていない場合、 nil が返ること' do
      @vending_machine.insert(100)
      _(@vending_machine.buy('コーラ')).must_be_nil
    end

    it '在庫がない場合、 nil が返ること' do
      5.times do
        @vending_machine.insert(100)
        @vending_machine.insert(20)
        @vending_machine.insert(20)
        @vending_machine.buy('コーラ')
      end
      _(@vending_machine.buy('コーラ')).must_be_nil
    end

    it 'ドリンクを購入した場合、その price と同じ値の分 sales_amount が増えること' do
      @vending_machine.insert(500)
      @vending_machine.buy('コーラ')
      _(@vending_machine.sales_amount).must_equal(120)
    end

    it 'ドリンクを購入した場合、 input_amount が 0 になること' do
      @vending_machine.insert(500)
      @vending_machine.buy('コーラ')
      _(@vending_machine.input_amount).must_equal(0)
    end

    it 'ドリンクを購入した場合、返した釣り銭の分 change が減ること' do
      @vending_machine.insert(500)
      @vending_machine.buy('コーラ')
      _(@vending_machine.change_stock[1000]).must_equal(5)
      _(@vending_machine.change_stock[10]).must_equal(7)
      _(@vending_machine.change_stock[50]).must_equal(9)
      _(@vending_machine.change_stock[100]).must_equal(7)
      _(@vending_machine.change_stock[500]).must_equal(11)
    end

    it 'ドリンクを購入した場合、在庫の量が減ること' do
      @vending_machine.insert(500)
      @vending_machine.buy('コーラ')
      _(@vending_machine.stock_tally['コーラ'][:count]).must_equal(4)
    end

    it 'ドリンクを購入できなかった場合、sales_amount が増えないこと' do
      @vending_machine.insert(100)
      @vending_machine.buy('コーラ')
      _(@vending_machine.sales_amount).must_equal(0)
    end

    it 'ドリンクを購入できなかった場合、input_amount が減らないこと' do
      @vending_machine.insert(100)
      @vending_machine.buy('コーラ')
      _(@vending_machine.input_amount).must_equal(100)
    end

    it 'ドリンクを購入できなかった場合、在庫が減らないこと' do
      @vending_machine.insert(100)
      @vending_machine.buy('コーラ')
      _(@vending_machine.stock_tally['コーラ'][:count]).must_equal(5)
    end

    it '釣り銭ストックが足りない場合、何もしないこと' do
      @vending_machine.instance_variable_set('@change_stock', { 10 => 0, 50 => 0, 100 => 0, 500 => 0, 1000 => 0 })
      @vending_machine.insert(500)
      @vending_machine.buy('コーラ')
      _(@vending_machine.input_amount).must_equal(500)
      _(@vending_machine.sales_amount).must_equal(0)
      _(@vending_machine.change_stock).must_equal({ 10 => 0, 50 => 0, 100 => 0, 500 => 1, 1000 => 0 })
      _(@vending_machine.stock_tally['コーラ'][:count]).must_equal(5)
    end

    it 'あたりイベントが発生したとき、同じジュースが 2 本出力される' do
      @vending_machine.stub(:get_prize?, true) do
        @vending_machine.insert(500)
        result = @vending_machine.buy('コーラ')
        _(result.size).must_equal(3)
        _(result[0]).must_be_instance_of(Cola)
        _(result[1]).must_be_instance_of(Cola)
        _(result[2]).must_equal(380)
      end
    end
  end

  describe '#get_prize?' do
    it 'そのドリンクの在庫がない場合、あたりが発生しないこと' do
      @vending_machine.instance_variable_set('@drink_stock', { 'コーラ' => [] })
      probability = Array.new(10000) { @vending_machine.get_prize?('コーラ') }.count { |v| v }.to_f / 10000 * 100
      _(probability).must_equal(0)
    end
  end

  describe '#sales_amount' do
    it '初期状態では 0 が返ること' do
      _(@vending_machine.sales_amount).must_equal(0)
    end

    it 'ドリンクを購入すると、購入された金額の合計額が返ること' do
      @vending_machine.insert(500)
      @vending_machine.buy('コーラ')
      _(@vending_machine.sales_amount).must_equal(120)
      @vending_machine.insert(500)
      @vending_machine.buy('コーラ')
      _(@vending_machine.sales_amount).must_equal(240)
    end
  end

  describe '#change_stock' do
    it '初期状態で、1000円札が 5枚、10円玉、50円玉、100円玉、500円玉 が 10 枚ずつ用意してあること' do
      _(@vending_machine.change_stock[1000]).must_equal(5)
      _(@vending_machine.change_stock[10]).must_equal(10)
      _(@vending_machine.change_stock[50]).must_equal(10)
      _(@vending_machine.change_stock[100]).must_equal(10)
      _(@vending_machine.change_stock[500]).must_equal(10)
    end
  end

  describe '#buyable_drinks' do
    it '購入可能なドリンクのリストが返ること' do
      @vending_machine.insert(100)
      @vending_machine.insert(50)
      _(@vending_machine.buyable_drinks).must_equal(%w(コーラ 水 ランダム))
    end
  end
end
