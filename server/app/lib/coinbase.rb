class Coinbase
    include HTTParty
    require 'openssl'
    require 'json'
    base_uri 'https://api.exchange.coinbase.com/products'
  
    DEFAULT_START_TIME = DateTime.new(2022, 7, 8,0,0,0).to_i.to_s
  
    def initialize
      @key = ENV['COINBASE_API_KEY']
      @secret = ENV['COINBASE_API_SECRET']     
      @pass = ENV['COINBASE_PASS']
      puts "key: " + @key + " secret: " + @secret + " pass: " + @pass     
    end

    
    def getPrices(pair:, start_time: DEFAULT_START_TIME,resolution: 3600)
        puts "start time in get prices: " +  DEFAULT_START_TIME
       response("/#{pair}/candles", start_time || DEFAULT_START_TIME,resolution)
    end

    private
    def get_signature(request_path='', timestamp=nil, method='GET')
        puts "timestamp: " + timestamp + " method: " + method + " request_path: " + request_path
        message = "#{timestamp}#{method}#{request_path}"
        # create a sha256 hmac with the secret
        secret = Base64.decode64(@secret)
        hash = Base64.strict_encode64(OpenSSL::HMAC.hexdigest('sha256', secret, message))
        puts "hash: " + hash
        return hash
    end

    def generate_headers(path)
        requestTimeStamp = Time.now.getutc.to_i.to_s
        headers = {
            "CB-ACCESS-KEY": @key,
            "CB-ACCESS-TIMESTAMP": requestTimeStamp,
            "CB-ACCESS-PASSPHRASE": @pass,
            "CB-ACCESS-SIGN": get_signature(path,requestTimeStamp)
        }
    end
    def response(path, start_time, resolution)
      time_now =  Time.now.getutc.to_i
      start_timestamp= start_time.to_i
      
      numCandles = (time_now-start_timestamp.to_i).div(resolution)
      
      if numCandles>300
        responses=[]
        Rails.logger.info "#{numCandles} candles exceeds maximum amount of 300, using pagination..."
        newStartTime = time_now - 298*resolution
        responses.concat self.class.get("#{path}?start=#{newStartTime.to_s}&end=#{time_now}&granularity=#{resolution}", headers: generate_headers(path)).parsed_response
        
        firstTime = responses.last()[0]
        puts "time now: "+time_now.to_s+" most recent time: " +responses[0][0].to_s+ " last time: " +firstTime.to_s
        newEndTime=firstTime-resolution
        while newEndTime>start_timestamp 
            newStartTime=newEndTime-299*resolution
            responses.concat self.class.get("#{path}?start=#{newStartTime.to_s}&end=#{newEndTime.to_s}&granularity=#{resolution}", headers: generate_headers(path))
            .parsed_response
            newEndTime=newEndTime-300*resolution
            newEndTime2=responses.last()[0]-resolution
            puts "newEndTime: "+newEndTime.to_s+ " newEndTime2: "+ newEndTime2.to_s
            if newEndTime<start_timestamp
                newEndTime=start_timestamp
            end
        end
      else
        puts "time now: " + time_now.to_s + " start timestamp: " + start_timestamp.to_s + " resolution: " + resolution.to_s  
        responses = self.class.get("#{path}?start=#{start_timestamp.to_s}&end=#{time_now.to_s}&granularity=#{resolution}", headers: generate_headers(path))
        responses = responses.parsed_response
        #puts responses
      end
      responses
      
    end
  
  end
  