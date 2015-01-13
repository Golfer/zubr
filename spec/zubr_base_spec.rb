describe Zubr do
  describe 'get response status 200' do
    it 'has response status success' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.status).to eq 200
    end

    it 'has response status not success' do
      get '/not_be_qood_status_response'
      expect(last_response.status).to eq 404
    end

    xit 'has response status taste' do
      get '/taste'
    end


    xit 'has response status cookorama' do
      get '/cookorama'
    end
  end
end