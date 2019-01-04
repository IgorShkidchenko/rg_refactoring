class CreditCardBase
  attr_accessor :balance
  attr_reader :number, :type

  VALID_TYPES = {
    usual: 'usual',
    capitalist: 'capitalist',
    virtual: 'virtual'
  }.freeze

  CARD_NUMBER_SIZE = 16
  VALID_CARD_NUMBERS = 10

  def initialize
    @number = generate_card_number
  end

  def self.find_type(input)
    VALID_TYPES.value?(input)
  end

  def put_money(amount)
    @balance += amount - put_tax(amount)
  end

  def operation_put_valid?(amount)
    amount >= put_tax(amount)
  end

  def withdraw_money(amount)
    @balance -= amount - withdraw_tax(amount)
  end

  def operation_withdraw_valid?(amount)
    (@balance - amount - withdraw_tax(amount)).positive?
  end

  def send_money(amount)
    @balance -= amount - sender_tax(amount)
  end

  def operation_send_valid?(amount)
    (@balance - amount - sender_tax(amount)).positive?
  end

  private

  def calculate_tax(amount:, percent_tax: 0, fixed_tax: 0)
    (amount / 100) * percent_tax + fixed_tax
  end

  def generate_card_number
    Array.new(CARD_NUMBER_SIZE) { rand(VALID_CARD_NUMBERS) }.join
  end
end
