require 'sinatra'
require 'sinatra/namespace'
require './service_client'
require './hc_data_store'

configure do
  set :json_services, ['https://commands.bim360dm-dev.autodesk.com/health', 'https://bim360dm-dev.autodesk.com/health?self=true']
  set :xml_services,  ['https://360-staging.autodesk.com/health']

  set :hc_data_store, HcDataStore.new(settings.json_services+settings.xml_services)
end

get '/' do
  erb :demo
end

namespace '/api/v1' do
  before do
    content_type 'application/json'
  end

  get '/health' do
    json_response = {}
    settings.json_services.each do |service|
      json_response[service] = ServiceClient.get_status(service)
    end

    settings.xml_services.each do |service|
      json_response[service] = ServiceClient.get_status(service, 'xml')
    end

    json_response.to_json
  end

  get '/availability' do
    json_response = {}
    all_services = settings.json_services+settings.xml_services
     
    all_services.each do |s|
      timestamp = Time.now.utc.to_i
      json_response[s] = settings.hc_data_store.get_last_hour_availability(s, timestamp)
    end

    json_response.to_json
  end

  # used by cron job (whenever gem) every minute
  get '/scheduled_health_check' do
    settings.json_services.each do |service|
      status = ServiceClient.get_status(service)
      settings.hc_data_store.add_health_status(service, status)
    end

    settings.xml_services.each do |service|
      status = ServiceClient.get_status(service, 'xml')
      settings.hc_data_store.add_health_status(service, status)
    end

    {:status => 'ok'}.to_json
  end

  # used for monitoring and debuging purposes
  get '/get_last_hour_samples' do
    json_response = {}
    all_services = settings.json_services+settings.xml_services
     
    all_services.each do |s|
      json_response[s] = {'up' => settings.hc_data_store.get_up_samples(s), 'down' => settings.hc_data_store.get_down_samples(s), 'unknown' => settings.hc_data_store.get_unknown_samples(s)}
    end

    json_response.to_json
  end
end
