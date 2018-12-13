class Virtual < Base
  attr_accessor :balance

  def initialize
    @balance = 50.0
    @number = generate_card_number
  end

  def withdraw_tax(amount)
    amount * 0.88
  end

  def put_tax(amount)
    amount * 1
  end

  def sender_tax
    1
  end
end
