class Capitalist < CreditCardBase
  TAXES = {
    put: 10,
    withdraw: 0.04,
    sender: 0.1
  }.freeze

  DEFAULT_BALANCE = 100.0

  def initialize(type)
    @type = type
    @balance = DEFAULT_BALANCE
    super()
  end

  def withdraw_tax(amount)
    amount * TAXES[:withdraw]
  end

  def put_tax(*)
    TAXES[:put]
  end

  def sender_tax(amount)
    amount * TAXES[:sender]
  end
end
