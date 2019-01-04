class Usual < CreditCardBase
  TAXES = {
    put: 2,
    withdraw: 5,
    sender: 20
  }.freeze

  DEFAULT_BALANCE = 50.0

  def initialize(type)
    @type = type
    @balance = DEFAULT_BALANCE
    super()
  end

  def put_tax(amount)
    calculate_tax(amount: amount, percent_tax: TAXES[:put])
  end

  def withdraw_tax(amount)
    calculate_tax(amount: amount, percent_tax: TAXES[:withdraw])
  end

  def sender_tax(amount)
    calculate_tax(amount: amount, fixed_tax: TAXES[:sender])
  end
end
