require 'sinatra/base'
require 'json'

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
