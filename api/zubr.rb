require 'sinatra'
require 'json'
require 'yaml'
require 'rest_client'

get '/' do
	content_type :json
	{ message: 'Hello World!' }.to_json
end


not_found do
	content_type :json
	halt 404, { error: 'URL not found' }.to_json
end