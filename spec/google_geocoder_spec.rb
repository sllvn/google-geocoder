require_relative '../google_geocoder'

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
  c.hook_into :faraday
end

describe GoogleGeocoder do
  describe '#encode' do
    context 'valid address' do
      before :all do
        VCR.use_cassette('valid_geocoding') do
          @result = GoogleGeocoder.encode('92 Lenora St Seattle, WA')
        end
      end

      it 'returns a hash with lat and lng keys' do
        @result.should be_instance_of Hash
        @result.should have_key(:lat)
        @result.should have_key(:lng)
      end

      it 'returns the correct geocoded latlng for a given address' do
        @result[:lat].should == 47.6116327
        @result[:lng].should == -122.3443489
      end

      it 'returns a correctly formatted address' do
        @result[:formatted_address].should == "92 Lenora Street, Seattle, WA 98121, USA"
      end
    end

    context 'invalid address' do
      it 'throws an exception if 0 or 2 or more results are returned' do
        VCR.use_cassette('invalid_geocoding') do
          expect {
            GoogleGeocoder.encode('Velociraptor')
          }.to raise_error(BadNumberOfResults)
        end
      end
    end
  end
end

