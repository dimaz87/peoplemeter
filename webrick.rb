require 'webrick'
require 'webrick/https'
require 'openssl'

ROOT_PATH = File.dirname(__FILE__)
CERT_PATH = ROOT_PATH + "/ssl_server"

ENV['RACK_ENV'] = :development.to_s unless ENV.has_key?('RACK_ENV') && !ENV['RACK_ENV'].empty?

if ENV['RACK_ENV'].to_sym == :nossl
  HOST_ADDRESS = '127.0.0.1'
  PORT_NUMBER = 8080
  SSL_ENABLE = false
end

if ENV['RACK_ENV'].to_sym == :development
  HOST_ADDRESS = '127.0.0.1'
  PORT_NUMBER = 8443
  SSL_ENABLE = true
end

if ENV['RACK_ENV'].to_sym == :test
  HOST_ADDRESS = '0.0.0.0'
  PORT_NUMBER = 8443
  SSL_ENABLE = true
end

if ENV['RACK_ENV'].to_sym == :production
  HOST_ADDRESS = '0.0.0.0'
  PORT_NUMBER = 443
  SSL_ENABLE = true
end

WEBRICK_OPTIONS = {
  :Port => PORT_NUMBER,
  :Host => HOST_ADDRESS,
  :Logger => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
  :DocumentRoot => ROOT_PATH,
  :SSLEnable => SSL_ENABLE,
  :SSLVerifyClient => OpenSSL::SSL::VERIFY_NONE,
  :SSLCertificate => OpenSSL::X509::Certificate.new(File.open(File.join(CERT_PATH, "cert")).read),
  :SSLPrivateKey => OpenSSL::PKey::RSA.new(File.open(File.join(CERT_PATH, "id_rsa")).read),
  :SSLCACertificateFile => File.join(CERT_PATH, "trustedCAs"),
  :SSLTimeout => 5
}

require_relative 'app'
Rack::Handler::WEBrick.run PeoplemeterServer,WEBRICK_OPTIONS
