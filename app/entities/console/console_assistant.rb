class ConsoleAssistant
  include Uploader

  COMMANDS = {
    create: 'create',
    load: 'load',
    accept: 'y',
    exit: 'exit',
    show_cards: 'SC',
    delete_account: 'DA',
    card_create: 'CC',
    card_destroy: 'DC',
    put_money: 'PM',
    withdraw_money: 'WM',
    send_money: 'SM'
  }.freeze

  def back?(input)
    input == COMMANDS[:exit]
  end

  def exit_console
    exit
  end

  def yes?
    user_input == COMMANDS[:accept]
  end

  def user_input
    gets.chomp
  end

  def output(message)
    puts message
  end
end
