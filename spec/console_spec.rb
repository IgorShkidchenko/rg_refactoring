RSpec.describe Console do
  OVERRIDABLE_FILENAME = 'spec/fixtures/account.yml'.freeze

  COMMON_PHRASES = {
    create_first_account: "There is no active accounts, do you want to be the first?[y/n]\n",
    destroy_account: "Are you sure you want to destroy account?[y/n]\n",
    if_you_want_to_delete: 'If you want to delete:',
    choose_card: 'Choose the card for putting:',
    choose_card_withdrawing: 'Choose the card for withdrawing:',
    input_amount: 'Input the amount of money you want to put on your card',
    withdraw_amount: 'Input the amount of money you want to withdraw'
  }.freeze

  HELLO_PHRASES = [
    'Hello, we are RubyG bank!',
    '- If you want to create account - press `create`',
    '- If you want to load account - press `load`',
    '- If you want to exit - press `exit`'
  ].freeze

  ASK_PHRASES = {
    name: 'Enter your name',
    login: 'Enter your login',
    password: 'Enter your password',
    age: 'Enter your age'
  }.freeze

  # rubocop:disable Metrics/LineLength

  CREATE_CARD_PHRASES = [
    'You could create one of 3 card types',
    '- Usual card. 2% tax on card INCOME. 20$ tax on SENDING money from this card. 5% tax on WITHDRAWING money. For creation this card - press `usual`',
    '- Capitalist card. 10$ tax on card INCOME. 10% tax on SENDING money from this card. 4$ tax on WITHDRAWING money. For creation this card - press `capitalist`',
    '- Virtual card. 1$ tax on card INCOME. 1$ tax on SENDING money from this card. 12% tax on WITHDRAWING money. For creation this card - press `virtual`',
    '- For exit - press `exit`'
  ].freeze

  # rubocop:enable Metrics/LineLength

  ACCOUNT_VALIDATION_PHRASES = {
    name: {
      first_letter: 'Your name must not be empty and starts with first upcase letter'
    },
    login: {
      present: 'Login must present',
      longer: 'Login must be longer then 4 symbols',
      shorter: 'Login must be shorter then 20 symbols',
      exists: 'Such account is already exists'
    },
    password: {
      present: 'Password must present',
      longer: 'Password must be longer then 6 symbols',
      shorter: 'Password must be shorter then 30 symbols'
    },
    age: {
      length: 'Your Age must be greeter then 23 and lower then 90'
    }
  }.freeze

  ERROR_PHRASES = {
    user_not_exists: 'There is no account with given credentials',
    wrong_command: 'Wrong command. Try again!',
    no_active_cards: "There is no active cards!\n",
    wrong_card_type: "Wrong card type. Try again!\n",
    wrong_number: "You entered wrong number!\n",
    correct_amount: 'You must input correct amount of money',
    tax_higher: 'Your tax is higher than input amount'
  }.freeze

  MAIN_OPERATIONS_TEXTS = [
    'If you want to:',
    '- show all cards - press SC',
    '- create card - press CC',
    '- destroy card - press DC',
    '- put money on card - press PM',
    '- withdraw money on card - press WM',
    '- send money to another card  - press SM',
    '- destroy account - press `DA`',
    '- exit from account - press `exit`'
  ].freeze

  CARDS = {
    usual: {
      type: 'usual',
      balance: 50.00
    },
    capitalist: {
      type: 'capitalist',
      balance: 100.00
    },
    virtual: {
      type: 'virtual',
      balance: 150.00
    }
  }.freeze

  let(:console) { described_class.new }

  let(:valid_string) { 'qweqwe' }
  let(:valid_age) { '26' }
  let(:valid_name) { 'John' }
  let(:real_account) { Account.new(name: valid_name, age: valid_age, login: valid_string, password: valid_string) }

  let(:card_console) { ConsoleForCards.new(real_account) }

  describe '#hello' do
    before { allow(console).to receive(:navigate_menu) }

    context 'when correct method calling' do
      it 'create account if input is create' do
        allow(console).to receive(:user_input).and_return('create')
        expect(console).to receive(:create_account_menu)
        console.hello
      end

      it 'load account if input is load' do
        allow(console).to receive(:user_input).and_return('load')
        expect(console).to receive(:load_account_menu)
        console.hello
      end

      it 'leave app if input is exit or some another word' do
        allow(console).to receive(:user_input).and_return('another')
        expect(console).to receive(:exit_console)
        console.hello
      end
    end
  end

  describe '#create' do
    let(:success_name_input) { 'Denis' }
    let(:success_age_input) { '72' }
    let(:success_login_input) { 'Denis' }
    let(:success_password_input) { 'Denis1993' }
    let(:success_create_command_input) { 'create' }
    let(:success_inputs) do
      [success_name_input,
       success_age_input, success_login_input, success_password_input]
    end

    context 'with success result' do
      before do
        allow(console).to receive_message_chain(:gets, :chomp).and_return(success_create_command_input, *success_inputs)
        allow(console).to receive(:navigate_menu)
        allow(console).to receive(:load_db).and_return([])
        stub_const('Uploader::PATH_TO_DB', OVERRIDABLE_FILENAME)
      end

      after do
        File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
      end

      it 'with correct outout' do
        allow(File).to receive(:open)
        ASK_PHRASES.values.each { |phrase| expect(console).to receive(:puts).with(phrase) }
        ACCOUNT_VALIDATION_PHRASES.values.map(&:values).each do |phrase|
          expect(console).not_to receive(:puts).with(phrase)
        end
        console.hello
      end

      it 'write to file Account instance' do
        console.hello
        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
        accounts = YAML.load_file(OVERRIDABLE_FILENAME)
        expect(accounts).to be_a Array
        expect(accounts.size).to be 1
        accounts.map { |account| expect(account).to be_a Account }
      end
    end

    context 'with errors' do
      before do
        all_inputs = [success_create_command_input] + current_inputs + success_inputs
        allow(File).to receive(:open)
        allow(console).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(console).to receive(:navigate_menu)
        allow(console).to receive(:load_db).and_return([])
        stub_const('Uploader::PATH_TO_DB', OVERRIDABLE_FILENAME)
      end

      context 'with name errors' do
        context 'without small letter' do
          let(:error_input) { 'some_test_name' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:name][:first_letter] }
          let(:current_inputs) do
            [error_input, success_age_input,
             success_login_input, success_password_input]
          end

          it { expect { console.hello }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with login errors' do
        let(:current_inputs) do
          [success_name_input, success_age_input,
           error_input, success_password_input]
        end

        context 'when present' do
          let(:error_input) { '' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:present] }

          it { expect { console.hello }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 3 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:longer] }

          it { expect { console.hello }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 21 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:shorter] }

          it { expect { console.hello }.to output(/#{error}/).to_stdout }
        end

        context 'when exists' do
          let(:error_input) { 'Denis1345' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:exists] }

          before do
            allow_any_instance_of(Account).to receive(:load_db) { [instance_double('Account', login: error_input)] }
          end

          it { expect { console.hello }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with age errors' do
        let(:current_inputs) { [success_name_input, error_input, success_login_input, success_password_input] }
        let(:error) { ACCOUNT_VALIDATION_PHRASES[:age][:length] }

        context 'with length minimum' do
          let(:error_input) { '22' }

          it { expect { console.hello }.to output(/#{error}/).to_stdout }
        end

        context 'with length maximum' do
          let(:error_input) { '91' }

          it { expect { console.hello }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with password errors' do
        let(:current_inputs) { [success_name_input, success_age_input, success_login_input, error_input] }

        context 'when absent' do
          let(:error_input) { '' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:present] }

          it { expect { console.hello }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 5 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:longer] }

          it { expect { console.hello }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 31 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:shorter] }

          it { expect { console.hello }.to output(/#{error}/).to_stdout }
        end
      end
    end
  end

  describe '#load' do
    let(:success_load_command_input) { 'load' }

    context 'without active accounts' do
      it do
        allow(console).to receive_message_chain(:gets, :chomp).and_return(success_load_command_input)
        allow(console).to receive(:navigate_menu)
        expect(console).to receive(:load_db).and_return([])
        expect(console).to receive(:ask_create_the_first_account).and_return([])
        console.hello
      end
    end

    context 'with active accounts' do
      let(:login) { 'Johnny' }
      let(:password) { 'johnny1' }
      let(:account_double) { instance_double('Account', login: login, password: password) }

      before do
        allow(console).to receive_message_chain(:gets, :chomp).and_return(success_load_command_input, *all_inputs)
        allow(console).to receive(:load_db) { [account_double] }
      end

      context 'with correct outout' do
        let(:all_inputs) { [login, password] }

        it do
          expect(console).to receive(:navigate_menu)
          [I18n.t('hello_message'), ASK_PHRASES[:login], ASK_PHRASES[:password]].each do |phrase|
            expect(console).to receive(:puts).with(phrase)
          end
          console.hello
        end
      end

      context 'when account exists' do
        let(:all_inputs) { [login, password] }

        it do
          expect(console).to receive(:navigate_menu)
          expect { console.hello }.not_to output(/#{ERROR_PHRASES[:user_not_exists]}/).to_stdout
        end
      end

      context 'when account doesn\t exists' do
        let(:all_inputs) { ['test', 'test', login, password] }

        it do
          expect(console).to receive(:navigate_menu)
          expect { console.hello }.to output(/#{ERROR_PHRASES[:user_not_exists]}/).to_stdout
        end
      end
    end
  end

  describe '#ask_create_the_first_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }

    it 'with correct outout' do
      expect(console).to receive_message_chain(:gets, :chomp) {}
      expect(console).to receive(:hello)
      expect { console.send(:ask_create_the_first_account) }.to output(COMMON_PHRASES[:create_first_account]).to_stdout
    end

    it 'calls create if user inputs is y' do
      expect(console).to receive_message_chain(:gets, :chomp) { success_input }
      expect(console).to receive(:create_account_menu)
      console.send(:ask_create_the_first_account)
    end

    it 'calls console if user inputs is not y' do
      expect(console).to receive_message_chain(:gets, :chomp) { cancel_input }
      expect(console).to receive(:hello)
      console.send(:ask_create_the_first_account)
    end
  end

  describe '#main_menu' do
    let(:name) { 'John' }
    let(:commands) do
      {
        'PM' => :put_money_menu,
        'SM' => :send_money_menu,
        'DC' => :destroy_card_menu,
        'WM' => :withdraw_money_menu,
        'SC' => :show_account_cards,
        'CC' => :create_new_card,
        'DA' => :destroy_account,
        'exit' => :exit_console
      }
    end

    context 'with correct outout' do
      it do
        allow(console).to receive(:show_account_cards)
        allow(console).to receive(:exit_console)
        allow(console).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
        console.instance_variable_set(:@account, instance_double('Account', name: name))
        expect { console.send(:navigate_menu) }.to output(/Welcome, #{name}/).to_stdout
        allow(console).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
        expect(console).to receive(:puts).with(I18n.t('main_menu_message', name: name)).twice
        console.send(:navigate_menu)
      end
    end

    context 'when commands used' do
      let(:undefined_command) { 'undefined' }

      it 'calls specific methods on predefined commands' do
        console.instance_variable_set(:@account, instance_double('Account', name: name, cards: [nil]))
        allow(console).to receive(:exit_console)
        allow_any_instance_of(ConsoleForCards).to receive(:update_db)

        commands.each_with_index do |(command, method_name), index|
          index > 3 ? (expect(console).to receive(method_name)) : (expect_any_instance_of(ConsoleForCards).to receive(method_name))
          allow(console).to receive_message_chain(:gets, :chomp).and_return(command, 'exit')
          console.send(:navigate_menu)
        end
      end

      it 'outputs incorrect message on undefined command' do
        console.instance_variable_set(:@account, instance_double('Account', name: name))
        expect(console).to receive(:exit_console)
        allow(console).to receive_message_chain(:gets, :chomp).and_return(undefined_command, 'exit')
        expect { console.send(:navigate_menu) }.to output(/#{ERROR_PHRASES[:wrong_command]}/).to_stdout
      end
    end
  end

  describe '#destroy_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }
    let(:correct_login) { 'test' }
    let(:fake_login) { 'test1' }
    let(:fake_login2) { 'test2' }
    let(:correct_account) { real_account }
    let(:fake_account) { instance_double('Account', login: fake_login) }
    let(:fake_account2) { instance_double('Account', login: fake_login2) }
    let(:accounts) { [correct_account, fake_account, fake_account2] }

    after do
      File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
    end

    it 'with correct outout' do
      expect(console).to receive_message_chain(:gets, :chomp) {}
      expect { console.send(:destroy_account) }.to output(COMMON_PHRASES[:destroy_account]).to_stdout
    end

    context 'when deleting' do
      it 'deletes account if user inputs is y' do
        stub_const('Uploader::PATH_TO_DB', OVERRIDABLE_FILENAME)
        allow(console).to receive(:exit_console)
        expect(console).to receive_message_chain(:gets, :chomp) { success_input }
        expect(correct_account).to receive(:load_db) { accounts }
        console.instance_variable_set(:@account, correct_account)

        console.send(:destroy_account)

        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
        file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
        expect(file_accounts).to be_a Array
        expect(file_accounts.size).to be 2
      end

      it 'doesnt delete account' do
        expect(console).to receive_message_chain(:gets, :chomp) { cancel_input }

        console.send(:destroy_account)

        expect(File.exist?(OVERRIDABLE_FILENAME)).to be false
      end
    end
  end

  describe '#show_cards' do
    let(:cards) do
      [instance_double('Usual', number: 1234, type: 'usual'),
       instance_double('Virtual', number: 5678, type: 'virtual')]
    end

    it 'display cards if there are any' do
      console.instance_variable_set(:@account, instance_double('Account', cards: cards))
      cards.each { |card| expect(console).to receive(:puts).with("- #{card.number}, #{card.type}") }
      console.send(:show_account_cards)
    end

    it 'outputs error if there are no active cards' do
      console.instance_variable_set(:@account, instance_double('Account', cards: []))
      expect(console).to receive(:puts).with(ERROR_PHRASES[:no_active_cards])
      console.send(:show_account_cards)
    end
  end

  describe '#create_card' do
    context 'with correct outout' do
      it do
        expect(console).to receive(:puts).with(I18n.t('create_card_phrases'))
        console.instance_variable_set(:@account, real_account)
        allow(console).to receive(:load_db).and_return([])
        allow(File).to receive(:open)
        expect(console).to receive_message_chain(:gets, :chomp) { 'usual' }

        console.send(:create_new_card)
      end
    end

    context 'when correct card choose' do
      before do
        allow(console).to receive(:load_db) { [real_account] }
        stub_const('Uploader::PATH_TO_DB', OVERRIDABLE_FILENAME)
        console.instance_variable_set(:@account, real_account)
      end

      after do
        File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
      end

      CARDS.each do |card_type, card_info|
        it "create card with #{card_type} type" do
          expect(console).to receive_message_chain(:gets, :chomp) { card_info[:type] }

          console.send(:create_new_card)

          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
          expect(file_accounts.first.cards.first.type).to eq card_info[:type]
          expect(file_accounts.first.cards.first.balance).to eq card_info[:balance]
          expect(file_accounts.first.cards.first.number.length).to be 16
        end
      end
    end

    context 'when incorrect card choose' do
      it do
        console.instance_variable_set(:@account, real_account)
        allow(File).to receive(:open)
        allow(console).to receive(:load_db).and_return([])
        allow(console).to receive_message_chain(:gets, :chomp).and_return('test', 'usual')

        expect { console.send(:create_new_card) }.to output(/#{ERROR_PHRASES[:wrong_card_type]}/).to_stdout
      end
    end
  end

  describe '#destroy_card' do
    context 'without cards' do
      it 'shows message about not active cards' do
        expect do
          card_console.send(:exist_cards_action, 'DC')
        end.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { instance_double('Usual', number: 1234, type: 'usual') }
      let(:card_two) { instance_double('Virtual', number: 5678, type: 'virtual') }
      let(:fake_cards) { [card_one, card_two] }

      context 'with correct outout' do
        it do
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
          allow(card_console).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect do
            card_console.send(:destroy_card_menu)
          end.to output(/#{COMMON_PHRASES[:if_you_want_to_delete]}/).to_stdout

          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { card_console.send(:destroy_card_menu) }.to output(message).to_stdout
          end
          card_console.send(:destroy_card_menu)
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
          expect(card_console).to receive_message_chain(:gets, :chomp) { 'exit' }
          card_console.send(:destroy_card_menu)
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
        end

        it do
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { card_console.send(:destroy_card_menu) }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { card_console.send(:destroy_card_menu) }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:accept_for_deleting) { 'y' }
        let(:reject_for_deleting) { 'asdf' }
        let(:deletable_card_number) { 1 }

        before do
          stub_const('Uploader::PATH_TO_DB', OVERRIDABLE_FILENAME)
          real_account.instance_variable_set(:@cards, fake_cards)
          allow(card_console).to receive(:load_db) { [real_account] }
          card_console.instance_variable_set(:@account, real_account)
        end

        after do
          File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
        end

        it 'accept deleting' do
          commands = [deletable_card_number, accept_for_deleting]
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { card_console.send(:exist_cards_action, 'DC') }.to change { real_account.cards.size }.by(-1)

          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
          expect(file_accounts.first.cards).not_to include(card_one)
        end

        it 'decline deleting' do
          commands = [deletable_card_number, reject_for_deleting]
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { card_console.send(:destroy_card_menu) }.not_to change(real_account.cards, :size)
        end
      end
    end
  end

  describe '#put_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        allow(card_console).to receive(:update_db)
        card_console.instance_variable_set(:@account, real_account)
        expect do
          card_console.send(:exist_cards_action, 'PM')
        end.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { instance_double('Usual', number: 1234, type: 'usual') }
      let(:card_two) { instance_double('Virtual', number: 5678, type: 'virtual') }
      let(:fake_cards) { [card_one, card_two] }

      context 'with correct outout' do
        it do
          allow(card_console).to receive(:update_db)
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
          allow(card_console).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { card_console.send(:exist_cards_action, 'PM') }.to output(/#{COMMON_PHRASES[:choose_card]}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { card_console.send(:exist_cards_action, 'PM') }.to output(message).to_stdout
          end
          card_console.send(:exist_cards_action, 'PM')
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(card_console).to receive(:update_db)
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
          expect(card_console).to receive_message_chain(:gets, :chomp) { 'exit' }
          card_console.send(:exist_cards_action, 'PM')
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(card_console).to receive(:update_db)
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
        end

        it do
          allow(card_console).to receive(:update_db)
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { card_console.send(:exist_cards_action, 'PM') }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(card_console).to receive(:update_db)
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { card_console.send(:exist_cards_action, 'PM') }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card_one) { Capitalist.new('capitalist') }
        let(:card_two) { instance_double('Capitalist', number: 2, type: 'capitalist', balance: 100.0) }
        let(:fake_cards) { [card_one, card_two] }
        let(:chosen_card_number) { 1 }
        let(:incorrect_money_amount) { -2 }
        let(:default_balance) { 50.0 }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:correct_money_amount_greater_than_tax) { 50 }

        before do
          card_one.instance_variable_set(:@balance, default_balance)
          real_account.instance_variable_set(:@cards, fake_cards)
          card_console.instance_variable_set(:@account, real_account)
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            allow(card_console).to receive(:update_db)
            expect do
              card_console.send(:exist_cards_action, 'PM')
            end.to output(/#{COMMON_PHRASES[:input_amount]}/).to_stdout
          end
        end

        context 'with amount lower then 0' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            allow(card_console).to receive(:update_db)
            expect do
              card_console.send(:exist_cards_action, 'PM')
            end.to output(/#{ERROR_PHRASES[:correct_amount]}/).to_stdout
          end
        end

        context 'with amount greater then 0' do
          context 'with tax greater than amount' do
            let(:commands) { [chosen_card_number, correct_money_amount_lower_than_tax] }

            it do
              allow(card_console).to receive(:update_db)
              expect do
                card_console.send(:exist_cards_action, 'PM')
              end.to output(/#{ERROR_PHRASES[:tax_higher]}/).to_stdout
            end
          end

          context 'with tax lower than amount' do
            let(:custom_cards) do
              [
                Usual.new('usual'),
                Capitalist.new('capitalist'),
                Virtual.new('virtual')
              ]
            end

            let(:commands) { [chosen_card_number, correct_money_amount_greater_than_tax] }

            after do
              File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
            end

            it do
              custom_cards.each do |custom_card|
                custom_card.instance_variable_set(:@balance, default_balance)
                real_account.instance_variable_set(:@cards, [custom_card, card_one, card_two])
                allow(card_console).to receive_message_chain(:gets, :chomp).and_return(*commands)
                allow(card_console).to receive(:load_db) { [real_account] }
                stub_const('Uploader::PATH_TO_DB', OVERRIDABLE_FILENAME)

                new_balance = default_balance + correct_money_amount_greater_than_tax - custom_card.put_tax(correct_money_amount_greater_than_tax)

                expect do
                  card_console.send(:exist_cards_action, 'PM')
                end.to output(
                  /Money #{correct_money_amount_greater_than_tax} was put on #{custom_card.number}. Balance: #{new_balance}. Tax: #{custom_card.put_tax(correct_money_amount_greater_than_tax)}/
                ).to_stdout

                expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
                file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
                expect(file_accounts.first.cards.first.balance).to eq(new_balance)
              end
            end
          end
        end
      end
    end
  end

  describe '#withdraw_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        allow(card_console).to receive(:update_db)
        card_console.instance_variable_set(:@account, real_account)
        expect do
          card_console.send(:exist_cards_action, 'WM')
        end.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { Capitalist.new('capitalist') }
      let(:card_two) { instance_double('Capitalist', number: 2, type: 'capitalist', balance: 100.0) }
      let(:fake_cards) { [card_one, card_two] }

      context 'with correct outout' do
        it do
          allow(card_console).to receive(:update_db)
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
          allow(card_console).to receive_message_chain(:gets, :chomp) { 'exit' }

          expect do
            card_console.send(:exist_cards_action, 'WM')
          end.to output(/#{COMMON_PHRASES[:choose_card_withdrawing]}/).to_stdout

          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { card_console.send(:exist_cards_action, 'WM') }.to output(message).to_stdout
          end
          card_console.send(:exist_cards_action, 'WM')
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(card_console).to receive(:update_db)
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
          expect(card_console).to receive_message_chain(:gets, :chomp) { 'exit' }
          card_console.send(:exist_cards_action, 'WM')
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(card_console).to receive(:update_db)
          allow(real_account).to receive(:cards) { fake_cards }
          card_console.instance_variable_set(:@account, real_account)
        end

        it do
          allow(card_console).to receive(:update_db)
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')

          expect do
            card_console.send(:exist_cards_action, 'WM')
          end.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(card_console).to receive(:update_db)
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')

          expect do
            card_console.send(:exist_cards_action, 'WM')
          end.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card_one) { Capitalist.new('capitalist') }
        let(:card_two) { instance_double('Capitalist', number: 2, type: 'capitalist', balance: 100.0) }
        let(:fake_cards) { [card_one, card_two] }
        let(:chosen_card_number) { 1 }
        let(:incorrect_money_amount) { -2 }
        let(:default_balance) { 50.0 }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:correct_money_amount_greater_than_tax) { 50 }

        before do
          real_account.instance_variable_set(:@cards, fake_cards)
          card_console.instance_variable_set(:@account, real_account)
          allow(card_console).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            allow(card_console).to receive(:update_db)

            expect do
              card_console.send(:exist_cards_action, 'WM')
            end.to output(/#{COMMON_PHRASES[:withdraw_amount]}/).to_stdout
          end
        end
      end
    end
  end
end
