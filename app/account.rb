class Account
  attr_accessor :cards
  attr_reader :current_account, :name, :password, :login, :age

  PATH_TO_DB = 'accounts.yml'.freeze

  def initialize
    @console = Console.new(self)
    @validator = ValidatorsAccount.new
  end

  def hello
    @console.hello
  end

  def show_cards
    @current_account.card.any? ? @console.show_cards(@current_account.card) : @console.output(I18n.t('error_phrases.no_active_cards'))
  end

  def create
    loop do
      @name = @console.name_input
      @age = @console.age_input
      @login = @console.login_input
      @password = @console.password_input

      @validator.validate(self)

      break if @validator.valid?

      @validator.puts_errors
    end

    @cards = []
    @current_account = self
    new_accounts = load_accounts << @current_account
    store_accounts(new_accounts)
    @console.main_menu
  end

  def create_card
    type = @console.credit_card_type
    CreditCard.new(type)
  end

  def load
    return @console.ask_create_the_first_account unless load_accounts.any?

    loop do
      login = @console.login_input
      password = @console.password_input

      @current_account = load_accounts.detect { |account| account.login == login || account.password == password }
      @current_account.nil? ? @console.output(I18n.t('error_phrases.user_not_exists')) : break
    end
    @console.main_menu
  end

  def destroy
    @console.output(I18n.t('common_phrases.destroy_account'))
    if @console.yes?
      new_accounts = load_accounts.map do |account|
        next if account.login == @current_account.login

        new_accounts.push(account)
      end
      store_accounts(new_accounts)
    end
    @console.exit_console
  end

  def load_accounts
    File.exists?(PATH_TO_DB) ? YAML.load_file(PATH_TO_DB) : []
  end

  private

  def store_accounts(new_accounts)
    File.open(PATH_TO_DB, 'w') { |f| f.write new_accounts.to_yaml }
  end
end
