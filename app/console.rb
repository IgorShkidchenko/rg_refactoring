class Console
  COMMANDS = {
    create: 'create',
    load: 'load',
    accept: 'yes',
    exit: 'exit',
    show_cards: 'SC',
    card_create: 'CC',
    card_destroy: 'DC',
    card_put_money: 'PM',
    card_withdraw_money: 'WM',
    card_send_money: 'SM',
    delete_account: 'DA'
  }.freeze

  def initialize(account)
    @account = account
  end

  def hello
    output(I18n.t('hello_message'))
    case user_input
    when COMMANDS[:create] then @account.create
    when COMMANDS[:load] then @account.load
    else exit_console
    end
  end

  def main_menu
    output(I18n.t('main_menu_message', name: @account.current_account.name))
    loop do
      case user_input
      when COMMANDS[:show_cards] then @account.show_cards
      when COMMANDS[:card_create] then @account.card.create
      when COMMANDS[:card_destroy] then @account.card.destroy
      when COMMANDS[:card_put_money] then @account.card.put_money
      when COMMANDS[:card_withdraw_money] then @account.card.withdraw_money
      when COMMANDS[:card_send_money] then @account.card.send_money
      when COMMANDS[:delete_account] then @account.destroy
      when COMMANDS[:exit] then exit_console
      else output(ERROR_PHRASES[:user_not_exists])
      end
    end
  end

  def name_input
    output(I18n.t('ask_phrases.name'))
    user_input
  end

  def age_input
    output(I18n.t('ask_phrases.age'))
    user_input.to_i
  end

  def login_input
    output(I18n.t('ask_phrases.login'))
    user_input
  end

  def password_input
    output(I18n.t('ask_phrases.password'))
    user_input
  end

  def ask_create_the_first_account
    output(I18n.t('common_phrases.create_first_account'))
    yes? ? @account.create : hello
  end

  def output(message)
    puts message
  end

  def show_cards(cards)
    cards.each { |card| output(I18n.t('common_phrases.create_first_account', number: card.number, type: card.type)) }
  end

  def yes?
    user_input == COMMANDS[:accept]
  end

  def exit_console
    exit
  end

  private

  def user_input
    gets.chomp
  end
end
