require 'sinatra/base'
require 'json'
require 'zlib'

STATS_PATH = ENV['STATS_PATH'] || File.join(File.dirname(__FILE__), "stats")

class PeoplemeterServer < Sinatra::Base
  before do
    content_type :txt
    Dir.mkdir STATS_PATH unless Dir.exist? STATS_PATH
  end

  configure :test do
    enable :logging
  end

  configure :production do
    disable :logging
  end

  configure :test, :production do
    #set :sn_pattern, /^[0-9]+$/
  end

  configure :development, :test do
    get '/help' do
      "Just a test\n"
    end
  end

  def check_sn(sn)
    return settings.sn_pattern =~ sn if settings.respond_to? :sn_pattern
    true
  end

  options '/statistic/:sn' do
    halt 400, "wrong serial number" unless check_sn params[:sn]
    headers "Allow" => "OPTIONS, POST"
    status 200
  end

  post '/statistic/:sn' do
    halt 400, "wrong serial number" unless check_sn params[:sn]
    halt 400, "empty request" if request.body.size == 0

    request_data = request.body.read
    stats_hash = JSON.parse(request_data.to_s)
    stats_hash[:ip] = request.ip
    request_data_with_ip = JSON.generate stats_hash

    halt 400, "no serial number" unless stats_hash.has_key? "serialNumber"
    serial_number = stats_hash["serialNumber"].to_s
    halt 400, "serial numbers in URI and in statistic should be equal" if params[:sn] != serial_number

    target_directory_path = File.join STATS_PATH, serial_number
    Dir.mkdir target_directory_path unless Dir.exist? target_directory_path
    File.open(File.join(target_directory_path, Time.now.utc.strftime('%Y%m%d-%H%M%S.%L')), 'w') do |out_file|
      gz = Zlib::GzipWriter.new out_file
      gz.write request_data_with_ip
      gz.close
    end

    status 204
  end
end
