require File.expand_path '../spec_helper.rb', __FILE__
require 'webmock/rspec'
require File.expand_path '../../service_client.rb', __FILE__
require File.expand_path '../../hc_data_store.rb', __FILE__

describe "Health Dashboard Service" do
  first_service_url  = "https://commands.bim360dm-dev.autodesk.com/health"
  second_service_url = "https://bim360dm-dev.autodesk.com/health?self=true"
  third_service_url  =  "https://360-staging.autodesk.com/health"
  
  context "Service client" do
    it "should return up status if overall status GOOD" do
      expected_body = {:status => {:overall => 'GOOD'}}
      stub_request(:get, first_service_url).
         to_return(status: 200, body: expected_body.to_json, headers: {})

      sc = ServiceClient.get_status(first_service_url)
      
      expect(sc).to be == 'up'
    end

    it "should return up status if overall status OK" do
      expected_body = {:status => {:overall => 'OK'}}
      stub_request(:get, first_service_url).
         to_return(status: 200, body: expected_body.to_json, headers: {})

      sc = ServiceClient.get_status(first_service_url)
      
      expect(sc).to be == 'up'
    end

    it "should return down status if service down" do
      expected_body = {:status => {:overall => 'NOT GOOD'}}
      stub_request(:get, second_service_url).
         to_return(status: 200, body: expected_body.to_json, headers: {})

      sc = ServiceClient.get_status(second_service_url)
      
      expect(sc).to be == 'down'
    end

    it "should return unknown status if service returns not 200 status" do
      url = "https://360-staging.autodesk.com/health"
      stub_request(:get, third_service_url).
         to_return(status: 500, body: {}.to_json, headers: {})

      sc = ServiceClient.get_status(third_service_url, 'xml')
      
      expect(sc).to be == 'unknown'
    end

    it "should return unknown status if we got service timeout" do
      url = "https://360-staging.autodesk.com/health"
      stub_request(:get, third_service_url).to_timeout

      sc = ServiceClient.get_status(third_service_url, 'xml')
      
      expect(sc).to be == 'unknown'
    end
  end
  
  context "Health check data store" do
    it "should have one up sample after we adding one up sample" do
      hds = HcDataStore.new([first_service_url])
      hds.add_health_status(first_service_url, 'up')

      expect(hds.get_up_samples(first_service_url).count).to be 1
    end

    it "get_last_hour_availability should return 'unknown' if 'up' + 'down' samples < 60" do
      hds = HcDataStore.new([first_service_url])

      expect(hds.get_last_hour_availability(first_service_url, Time.now.utc.to_i)).to be == 'unknown'
    end
  end
end