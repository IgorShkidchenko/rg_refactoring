class ConsoleForCards < ConsoleAssistant
  def initialize(account)
    @account = account
  end

  def exist_cards_action(command)
    return output(I18n.t('error_phrases.no_active_cards')) if @account.cards.empty?

    case command
    when COMMANDS[:card_destroy] then destroy_card_menu
    when COMMANDS[:put_money] then put_money_menu(command)
    when COMMANDS[:withdraw_money] then withdraw_money_menu(command)
    when COMMANDS[:send_money] then send_money_menu(command)
    end
    update_db(@account)
  end

  private

  def destroy_card_menu
    output(I18n.t('common_phrases.if_you_want_to_delete'))
    chosen_card = select_card
    return unless chosen_card

    output(I18n.t('common_phrases.destroy_card', card: chosen_card.number))
    return unless yes?

    @account.cards.delete(chosen_card)
  end

  def put_money_menu(command)
    operation = take_operation_data_from_user(command)
    return unless operation

    card = operation[:chosen_card]
    amount = operation[:amount]
    return output(I18n.t('error_phrases.tax_higher')) unless card.operation_put_valid?(amount)

    card.put_money(amount)
    output(I18n.t('common_phrases.after_put', amount: amount, number: card.number,
                                              balance: card.balance, tax: card.put_tax(amount)))
  end

  def withdraw_money_menu(command)
    operation = take_operation_data_from_user(command)
    return unless operation

    card = operation[:chosen_card]
    amount = operation[:amount]
    return output(I18n.t('error_phrases.no_money_left')) unless card.operation_withdraw_valid?(amount)

    card.withdraw_money(amount)
    output(I18n.t('common_phrases.after_withdraw', amount: amount, number: card.number,
                                                   balance: card.balance, tax: card.withdraw_tax(amount)))
  end

  def send_money_menu(command)
    operation = take_operation_data_from_user(command)
    return unless operation

    sender_card = operation[:chosen_card]
    amount = operation[:amount]
    output(I18n.t('common_phrases.recipient_card'))
    recipient_card = validate_recipiet_card
    return unless recipient_card
    return unless validate_send_operation_taxes(sender_card, recipient_card, amount)

    send_money_operation(sender_card, recipient_card, amount)
  end

  def validate_send_operation_taxes(sender_card, recipient_card, amount)
    return output(I18n.t('error_phrases.no_money_left')) unless sender_card.operation_send_valid?(amount)
    return output(I18n.t('error_phrases.no_money_on_recipient')) unless recipient_card.operation_put_valid?(amount)

    true
  end

  def send_money_operation(sender_card, recipient_card, amount)
    sender_card.send_money(amount)
    recipient_card.put_money(amount)
    output(I18n.t('common_phrases.after_withdraw', amount: amount, number: sender_card.number,
                                                   balance: sender_card.balance, tax: sender_card.sender_tax(amount)))
    output(I18n.t('common_phrases.after_put', amount: amount, number: recipient_card.number,
                                              balance: recipient_card.balance, tax: recipient_card.put_tax(amount)))
  end

  def validate_recipiet_card
    input_number = user_input
    return output(I18n.t('error_phrases.invalid_number')) if input_number.size != CreditCardBase::CARD_NUMBER_SIZE

    finded_card = @account.cards.detect { |card| card.number == input_number }
    finded_card || output(I18n.t('error_phrases.not_exist_card_number', number: input_number))
  end

  def take_operation_data_from_user(command)
    action = COMMANDS.key(command)
    output(I18n.t("operations.choose_card.#{action}"))
    chosen_card = select_card
    return unless chosen_card

    output(I18n.t("operations.amount.#{action}"))
    amount = validate_amount
    return unless amount

    { chosen_card: chosen_card, amount: amount }
  end

  def validate_amount
    amount = user_input.to_i
    amount.positive? ? amount : output(I18n.t('error_phrases.correct_amount'))
  end

  def select_card
    show_cards_with_index
    choice = user_input
    return if back?(choice)
    return output(I18n.t('error_phrases.wrong_number')) unless (1..@account.cards.size).cover?(choice.to_i)

    @account.find_card_by_index(choice)
  end

  def show_cards_with_index
    @account.cards.each_with_index do |card, index|
      output(I18n.t('common_phrases.show_cards_for_destroying', number: card.number,
                                                                type: card.type, index: index + 1))
    end
    output(I18n.t('common_phrases.press_exit'))
  end
end
