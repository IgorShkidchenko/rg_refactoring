class ConsoleAssistant
  include Uploader

  COMMANDS = {
    account: {
      create: 'create',
      load: 'load',
      delete_account: 'DA'
    },

    main: {
      accept: 'y',
      exit: 'exit'
    },

    card: {
      show_cards: 'SC',
      card_create: 'CC',
      card_destroy: 'DC',
      put_money: 'PM',
      withdraw_money: 'WM',
      send_money: 'SM'
    }
  }.freeze

  def back?(input)
    input == COMMANDS[:main][:exit]
  end

  def exit_console
    exit
  end

  def ask_for_accept?
    user_input == COMMANDS[:main][:accept]
  end

  def user_input
    gets.chomp
  end

  def output(message, **hash)
    puts I18n.t(message, hash)
  end
end
