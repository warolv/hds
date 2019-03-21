require 'rest-client'
require 'json'
require 'nokogiri'

class ServiceClient
  def self.get_status(url, type = 'json')
    begin
      response = RestClient.get(url)
      
      if response.code == 200
        if type == 'json'
          ['good','ok'].include?(JSON.parse(response)['status']['overall'].to_s.downcase) ? 'up' : 'down'
        else # xml
          Nokogiri::XML(response).xpath('//status').inner_text.to_s.downcase == 'good' ? 'up' : 'down'
        end
      else
        'unknown'
      end
    rescue # in case of timeout or some unexpected problem with service
      'unknown'
    end
  end
end

