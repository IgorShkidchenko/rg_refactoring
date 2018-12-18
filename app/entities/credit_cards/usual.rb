class Usual < CreditCardBase
  TAXES = {
    put: 0.02,
    withdraw: 0.05,
    sender: 20
  }.freeze

  DEFAULT_BALANCE = 50.0

  def initialize(type)
    @type = type
    @balance = DEFAULT_BALANCE
    super()
  end

  def withdraw_tax(amount)
    amount * TAXES[:withdraw]
  end

  def put_tax(amount)
    amount * TAXES[:put]
  end

  def sender_tax(*)
    TAXES[:sender]
  end
end
