class Virtual < CreditCardBase
  TAXES = {
    put: 1,
    withdraw: 0.88,
    sender: 1
  }.freeze

  DEFAULT_BALANCE = 150.0

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

  def sender_tax(*)
    TAXES[:sender]
  end
end
