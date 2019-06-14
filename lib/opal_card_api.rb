require 'mechanize'
require 'tzinfo'
require 'caching_enumerator'
require 'uri'

require 'opal_card_api/version'

class OpalCardApi

	DOMAIN = 'www.opal.com.au'.freeze
	BASE_URI = URI "https://#{DOMAIN}/"

	class Error < StandardError; end

	class JsonParser < Mechanize::Page
		attr_reader :json
		def initialize(uri=nil, response=nil, body=nil, code=nil)
			@json = JSON.parse body
			super uri, response, body, code
		end
	end

	def initialize(
		username: ENV['OPAL_USERNAME'],
		password: ENV['OPAL_PASSWORD']
	)

		raise ArgumentError, 'No username provided' unless username
		raise ArgumentError, 'No password provided' unless password

		@username     = username
		@password     = password
		@logged_in    = false
		@transactions = {}
	end

	def agent
		@agent ||= Mechanize.new do |a|
			a.user_agent = 'Opal Card API Client (cyclotron3k)'
			a.pluggable_parser['application/json'] = JsonParser
			a.max_history = 0
		end
	end

	# rubocop:disable Style/RescueStandardError
	def login
		@logged_in = true
		page = get ''

		page = page.form_with(
			method: 'POST',
			action: %r{/registeredUserUsernameAndPasswordLogin\z}
		) do |form|
			form.h_username = @username
			form.h_password = @password
		end.submit

		raise Error, page.json['errorMessage'].to_s unless page.json['validationFailure'] == false
	rescue
		@logged_in = false
		raise
	end
	# rubocop:enable Style/RescueStandardError

	def cards
		@cards ||= get(
			'/registered/getJsonCardDetailsArray',
			'_' => DateTime.now.strftime('%Q')
		).json
	end

	def transactions(card_identifier=0)

		card_index = identify_card_index card_identifier

		@transactions[card_index] ||= CachingEnumerator.new do |yielder|
			tz = TZInfo::Timezone.get 'Australia/Sydney'
			page_no = 1
			running = true

			while running
				page = get(
					'/registered/opal-card-transactions/opal-card-activities-list',
					'AMonth'    => -1,
					'AYear'     => -1,
					'cardIndex' => card_index,
					'pageIndex' => page_no,
					'_'         => DateTime.now.strftime('%Q')
				)

				page.css('tr').drop(1).each do |row|
					cols = row.css 'td'

					mode = if cols[2].at_css('img')
						cols[2].at_css('img').attr 'alt'
					else
						''
					end

					timestamp = tz.local_time(
						*cols[1].text.match(
							%r{0*(\d+)/0*(\d+)/(\d{4})\s*0*(\d+):0*(\d+)}
						).captures.map(
							&:to_i
						).values_at(2, 1, 0, 3, 4)
					)

					yielder.yield(
						id:             cols[0].text.to_i,
						timestamp:      timestamp,
						mode:           mode,
						description:    cols[3].text,
						journey_number: cols[4].text.strip.to_i,
						fare_applied:   cols[5].text,
						fare:           cols[6].text,
						discount:       cols[7].text,
						amount:         cols[8].text
					)
				end

				page_no += 1
				running = false unless page.at_css('a[title="Next page"]')

			end

		end

	end

	private

	def identify_card_index(identifier)
		case identifier
		when Integer
			if identifier < 1000
				identifier
			else
				cards.index { |c| c[:cardNumber] == identifier.to_s }
			end
		when String
			cards.index do |c|
				%w[cardNumber cardNickName displayName].any? { |k| c[k] == identifier }
			end
		when Hash
			cards.index { |c| c == identifier }
		end or raise Error, 'Invalid card identifier'
	end

	def generate_url(path, params={})
		pr = BASE_URI + path
		pr.query = URI.encode_www_form(params) unless params.empty?
		pr.to_s
	end

	def get(*args)
		login unless @logged_in
		agent.get generate_url(*args)
	end

end
