class Virtual < CreditCardBase
  TAXES = {
    put: 1,
    withdraw: 12,
    sender: 1
  }.freeze

  DEFAULT_BALANCE = 150.0

  def initialize(type)
    @type = type
    @balance = DEFAULT_BALANCE
    super()
  end

  def withdraw_tax(amount)
    calculate_tax(amount: amount, percent_tax: TAXES[:withdraw])
  end

  def put_tax(amount)
    calculate_tax(amount: amount, fixed_tax: TAXES[:put])
  end

  def sender_tax(amount)
    calculate_tax(amount: amount, fixed_tax: TAXES[:sender])
  end
end
