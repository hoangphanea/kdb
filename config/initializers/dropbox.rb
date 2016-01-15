require 'dropbox_sdk'

DBENV = YAML.load_file(Rails.root.join('config', 'config.yml'))
ACCESS_TOKEN = DBENV['db_key']
$client = DropboxClient.new(ACCESS_TOKEN)
$session = session = DropboxOAuth2Session.new(ACCESS_TOKEN, nil)
