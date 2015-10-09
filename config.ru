ENV['RACK_ENV'] = 'production'

$LOAD_PATH << '.'
require 'app'

run PeoplemeterServer
