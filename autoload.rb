require 'yaml'
require 'pry'
require 'i18n'

require_relative 'app/modules/uploader'
require_relative 'app/entities/credit_cards/credit_card_base'
require_relative 'app/entities/credit_cards/capitalist'
require_relative 'app/entities/credit_cards/usual'
require_relative 'app/entities/credit_cards/virtual'
require_relative 'app/entities/account'
require_relative 'app/entities/console/console_assistant'
require_relative 'app/entities/console/console_for_cards'
require_relative 'app/entities/console/console_main'
I18n.load_path << Dir[File.expand_path('locales') + '/*.yml']
