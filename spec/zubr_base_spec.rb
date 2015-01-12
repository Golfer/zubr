describe Zubr do
  include Rack::Test::Methods
  describe 'get response status 200' do
    it 'has response status success' do
      get '/'
      #expect(last_response).to be_ok
      p last_response
      p last_response.body
      p last_response.status
    end

    it 'has response status success' do
      get '/not_be_qood_status_response'
      #expect(last_response).to be_ok
      p last_response
      p last_response.body
      p last_response.status
    end

    it 'has response status taste' do
      get '/taste'
      #expect(last_response).to be_ok
      p last_response
      p last_response.body
      p last_response.status
    end


    it 'has response status cookorama' do
      get '/cookorama'
      #expect(last_response).to be_ok
      p last_response
      p last_response.body
      p last_response.status
    end
  end
end