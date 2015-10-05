require 'webrick'
require 'webrick/https'
require 'openssl'

ROOT_PATH = File.dirname(__FILE__)
CERT_PATH = ROOT_PATH + "/ssl"

#HOST_ADDRESS = '127.0.0.1'
HOST_ADDRESS = '0.0.0.0'

WEBRICK_OPTIONS = {
  :Port => 443,
  :Host => HOST_ADDRESS,
  :Logger => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
  :DocumentRoot => ROOT_PATH,
  :SSLEnable => true,
  :SSLVerifyClient => OpenSSL::SSL::VERIFY_PEER,
  :SSLCertificate => OpenSSL::X509::Certificate.new(File.open(File.join(CERT_PATH, "cert")).read),
  :SSLPrivateKey => OpenSSL::PKey::RSA.new(File.open(File.join(CERT_PATH, "id_rsa")).read),
  :SSLCACertificateFile => File.join(CERT_PATH, "trust_ca"),
  :SSLTimeout => 5
}

require_relative 'app'
Rack::Handler::WEBrick.run PeoplemeterServer,WEBRICK_OPTIONS
