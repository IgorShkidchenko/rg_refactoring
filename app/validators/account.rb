class ValidatorsAccount
  attr_reader :errors

  def initialize
    @errors = []
  end

  def validate(account)
    initialize_account(account)

    validate_name
    validate_age
    validate_login
    validate_password
  end

  def valid?
    @errors.size.zero?
  end

  def puts_errors
    @errors.each { |error| puts error }
    @errors = []
  end

  private

  def initialize_account(account)
    @account = account
    @name = @account.name
    @age = @account.age
    @login = @account.login
    @password = @account.password
  end

  def validate_name
    if @name.empty? || @name[0].upcase != @name[0]
      @errors.push(I18n.t('account_validation_phrases.name.first_letter'))
    end
  end

  def validate_login
    @errors.push(I18n.t('account_validation_phrases.login.present')) if @login.empty?
    @errors.push(I18n.t('account_validation_phrases.login.longer')) if @login.length < 4
    @errors.push(I18n.t('account_validation_phrases.login.shorter')) if @login.length > 20
    @errors.push(I18n.t('account_validation_phrases.login.exists')) if account_exists
  end

  def validate_password
    @errors.push(I18n.t('account_validation_phrases.password.present')) if @password.empty?
    @errors.push(I18n.t('account_validation_phrases.password.longer')) if @password.length < 6
    @errors.push(I18n.t('account_validation_phrases.password.shorter')) if @password.length > 30
  end

  def validate_age
    @errors.push(I18n.t('account_validation_phrases.age.length')) unless @age.between?(23, 89)
  end

  def account_exists
    @account.load_accounts.detect { |acc| acc.login == @login }
  end
end
