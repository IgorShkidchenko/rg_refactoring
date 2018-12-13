class Base
  def withdraw_tax
    raise NotImplementedError
  end

  def put_tax
    raise NotImplementedError
  end

  def sender_tax
    raise NotImplementedError
  end

  private

  def generate_card_number
    Array.new(16) { rand(10) }.join
  end
end
