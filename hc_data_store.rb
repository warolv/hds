class HcDataStore
  def initialize(services)
    @data_store = Hash.new
    services.each do |s|
      @data_store[s] = Hash.new
      @data_store[s]['up'], @data_store[s]['down'], @data_store[s]['unknown'] = [], [], []
    end
  end

  def add_health_status(service, status)
    status_array = @data_store[service][status]
    status_array << Time.now.utc.to_i
    @data_store[service][status] = status_array.last(60) # save only last 60 elements in array
  end

  def get_up_samples(service)
    @data_store[service]['up']
  end

  def get_down_samples(service)
    @data_store[service]['down']
  end

  def get_unknown_samples(service)
    @data_store[service]['unknown']
  end

  def get_last_hour_availability(service, timestamp)
    last_hour_up_samples   = get_up_samples(service).select{|ts| (ts <= timestamp) && (ts >= timestamp-60*60)}.count
    last_hour_down_samples = get_down_samples(service).select{|ts| (ts <= timestamp) && (ts >= timestamp-60*60)}.count
    if last_hour_up_samples + last_hour_down_samples == 60
      "#{last_hour_up_samples / 60.0 * 100}%"
    else
      'unknown'
    end
  end
end
