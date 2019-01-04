class Console < ConsoleAssistant
  def hello
    output('hello_message')
    case user_input
    when COMMANDS[:account][:create] then create_account_menu
    when COMMANDS[:account][:load] then load_account_menu
    else exit_console
    end
    navigate_menu
  end

  private

  def create_account_menu
    loop do
      @account = Account.new(take_account_info_from_user(name: '', age: '', login: '', password: ''))
      @account.valid? ? break : output(@account.errors.join("\n"))
    end
    update_db(@account)
  end

  def take_account_info_from_user(hash_data)
    hash_data.each_pair do |data_key, data_value|
      output("ask_phrases.#{data_key}")
      data_value.replace(user_input)
    end
  end

  def load_account_menu
    loaded_db = load_db
    return ask_create_the_first_account if loaded_db.empty?

    loop do
      @account = Account.find_in_db(take_account_info_from_user(login: '', password: ''), loaded_db)
      @account ? break : output('error_phrases.user_not_exists')
    end
  end

  def ask_create_the_first_account
    output('common_phrases.create_first_account')
    ask_for_accept? ? create_account_menu : hello
  end

  def navigate_menu
    loop do
      output('main_menu_message', name: @account.name)
      case command = find_command
      when COMMANDS[:card][:show_cards] then show_account_cards
      when COMMANDS[:account][:delete_account] then destroy_account
      when COMMANDS[:card][:card_create] then create_new_card
      when COMMANDS[:main][:exit] then return exit_console
      else redirect_to_console_for_cards(command)
      end
    end
  end

  def find_command
    loop do
      command = user_input
      return command if COMMANDS.values.reduce({}, :merge).value?(command)

      output('error_phrases.wrong_command')
    end
  end

  def destroy_account
    output('common_phrases.destroy_account')
    return unless ask_for_accept?

    @account.destroy
    exit_console
  end

  def show_account_cards
    return output('error_phrases.no_active_cards') if @account.cards.empty?

    @account.cards.each { |card| output('common_phrases.show_cards', number: card.number, type: card.type) }
  end

  def create_new_card
    loop do
      output('create_card_phrases')
      type = user_input
      break @account.create_new_card(type) if CreditCardBase.find_type(type)

      output('error_phrases.wrong_card_type')
    end
    update_db(@account)
  end

  def redirect_to_console_for_cards(command)
    ConsoleForCards.new(@account).exist_cards_action(command)
  end
end
