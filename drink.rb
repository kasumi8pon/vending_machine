require 'date'

class Drink
  attr_reader :expired_on

  def initialize(expired_on)
    @expired_on = Date.parse(expired_on)
  end

  def expired?(today = Date.today)
    today > expired_on
  end
end
class Cola < Drink
  def self.name
    'コーラ'
  end

  def self.price
    120
  end
end

class DietCola < Drink
  def self.name
    'ダイエットコーラ'
  end

  def self.price
    120
  end
end

class Tea < Drink
  def self.name
    'お茶'
  end

  def self.price
    120
  end
end

class Redbull < Drink
  def self.name
    'レッドブル'
  end

  def self.price
    200
  end
end

class Water < Drink
  def self.name
    '水'
  end

  def self.price
    100
  end
end
