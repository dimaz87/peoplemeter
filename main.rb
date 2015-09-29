require 'sinatra/base'
require 'webrick'
require 'webrick/https'
require 'openssl'
require 'json'

CERT_PATH = '/home/dmitriyz/Downloads/pki/'

#HOST_ADDRESS = '127.0.0.1'
HOST_ADDRESS = '0.0.0.0'

WEBRICK_OPTIONS = {
  :Port => 8443,
  :Host => HOST_ADDRESS,
  :Logger => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
  :DocumentRoot => '/home/projects/ruby/peoplemeter/',
  :SSLEnable => true,
  :SSLVerifyClient => OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT,
  :SSLCertificate => OpenSSL::X509::Certificate.new(File.open(File.join(CERT_PATH, "cert")).read),
  :SSLPrivateKey => OpenSSL::PKey::RSA.new(File.open(File.join(CERT_PATH, "id_rsa")).read),
  :SSLCACertificateFile => File.join(CERT_PATH, "chain"),
  :SSLTimeout => 5
}

def check_sn(sn)
  true
end

class PeoplemeterServer < Sinatra::Base
  before do
    content_type :txt
  end

  options '/statistic/:sn' do
    halt 400 unless check_sn params[:sn]
    headers "Allow" => "OPTIONS, POST"
  end

  post '/statistic/:sn' do
    halt 400 unless check_sn params[:sn]
    halt 400 if request.body.size == 0
    requestData = request.body.read
    statsHash = JSON.parse(requestData.to_s)
    status 202
  end
end

Rack::Handler::WEBrick.run PeoplemeterServer,WEBRICK_OPTIONS
