require 'sinatra/base'
require 'json'

ROOT_PATH = File.dirname(__FILE__)
STATS_PATH = ROOT_PATH + "/stats"

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
    status 200
  end

  post '/statistic/:sn' do
    halt 400 unless check_sn params[:sn]
    halt 400 if request.body.size == 0
    requestData = request.body.read
    statsHash = JSON.parse(requestData.to_s)
    statsHash.merge!({ "sn" => params[:sn] })
    target = File.open(File.join(STATS_PATH, Time.now.strftime('%Y%m%d%H%M%S%L')), 'w')
    target.write(statsHash.to_json)
    target.close
    status 204
  end
end
