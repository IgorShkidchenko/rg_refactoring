class Account
  attr_reader :name, :login, :password, :errors, :cards

  include Uploader

  VALID_RANGE = {
    age: (23..89),
    login: (4..20),
    password: (6..30)
  }.freeze

  def initialize(new_account_data)
    @name = new_account_data[:name]
    @age = new_account_data[:age].to_i
    @login = new_account_data[:login]
    @password = new_account_data[:password]
    @cards = []
    @errors = []
  end

  def valid?
    validate
    @errors.empty?
  end

  def destroy
    save_to_db(load_db.reject { |account| account.login == @login })
  end

  def create_new_card(type)
    case type
    when CreditCardBase::VALID_TYPES[:usual] then @cards << Usual.new(type)
    when CreditCardBase::VALID_TYPES[:capitalist] then @cards << Capitalist.new(type)
    when CreditCardBase::VALID_TYPES[:virtual] then @cards << Virtual.new(type)
    end
  end

  def find_card_by_index(choice)
    @cards[choice.to_i - 1]
  end

  def self.find_in_db(user_data_inputs, loaded_db)
    loaded_db.detect do |db_acc|
      db_acc.login == user_data_inputs[:login] && db_acc.password == user_data_inputs[:password]
    end
  end

  private

  def validate
    validate_login
    validate_name
    validate_age
    validate_password
  end

  def validate_name
    @errors << I18n.t('account_validation_phrases.name.first_letter') unless first_letter_uppcase?
  end

  # rubocop:disable Metrics/AbcSize

  def validate_login
    @errors << I18n.t('account_validation_phrases.login.present') if @login.empty?
    @errors << I18n.t('account_validation_phrases.login.longer') if @login.size < VALID_RANGE[:login].min
    @errors << I18n.t('account_validation_phrases.login.shorter') if @login.size > VALID_RANGE[:login].max
    @errors << I18n.t('account_validation_phrases.login.exists') if account_exists?
  end

  def validate_password
    @errors << I18n.t('account_validation_phrases.password.present') if @password.empty?
    @errors << I18n.t('account_validation_phrases.password.longer') if @password.size < VALID_RANGE[:password].min
    @errors << I18n.t('account_validation_phrases.password.shorter') if @password.size > VALID_RANGE[:password].max
  end

  # rubocop:enable Metrics/AbcSize

  def validate_age
    @errors << I18n.t('account_validation_phrases.age.length') unless (VALID_RANGE[:age]).cover?(@age)
  end

  def first_letter_uppcase?
    @name.capitalize[0] == @name[0]
  end

  def account_exists?
    load_db.detect { |account_in_db| account_in_db.login == @login }
  end
end
