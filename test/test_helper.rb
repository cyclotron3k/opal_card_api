$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'opal_card_api'
require 'minitest/autorun'
require 'webmock/minitest'
require 'vcr'

VCR.configure do |config|
	config.cassette_library_dir = 'test/fixtures/vcr_cassettes'
	config.hook_into :webmock
	config.allow_http_connections_when_no_cassette = false

	config.register_request_matcher :uri_ignoring_cb do |*requests|
		requests.map(&:uri).map do |uri|
			uri.sub(/\b_=\d+/, 'CACHE_BUSTER')
		end.reduce(&:==)
	end

	config.default_cassette_options = {
		match_requests_on: %i[method headers uri_ignoring_cb]
	}
end
