module Uploader
  DB_NAME = 'database'.freeze
  DB_PATH = '/accounts'.freeze
  DB_FORMAT = '.yml'.freeze

  PATH_TO_DB = DB_NAME + DB_PATH + DB_FORMAT

  def save_to_db(new_accounts)
    File.open(PATH_TO_DB, 'w') { |f| f.write new_accounts.to_yaml }
  end

  def load_db
    File.exist?(PATH_TO_DB) ? YAML.load_file(PATH_TO_DB) : []
  end

  def update_db(entity)
    loaded_db = load_db
    loaded_db << entity
    save_to_db(loaded_db.reverse.uniq(&:login))
  end
end
