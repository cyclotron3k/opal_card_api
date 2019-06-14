require 'test_helper'

class OpalCardApiTest < Minitest::Test
	def test_that_it_has_a_version_number
		refute_nil ::OpalCardApi::VERSION
	end

	def test_successful_login
		VCR.use_cassette('login_success') do
			client = OpalCardApi.new username: 'test', password: 'test'
			client.login
		end
	end

	def test_failed_login
		VCR.use_cassette('login_failure') do
			e = assert_raises(OpalCardApi::Error) do
				client = OpalCardApi.new username: 'test', password: 'test'
				client.login
			end
			assert_equal 'This username or password does not match our records, please try again', e.message
		end
	end

	def test_blocked_login
		VCR.use_cassette('login_blocked') do
			e = assert_raises(OpalCardApi::Error) do
				client = OpalCardApi.new username: 'test', password: 'test'
				client.login
			end
			assert_equal 'Your Opal account is blocked. Although you can still use your Opal card, you\'ll need to contact Opal Customer Care on 13 67 25 (13 OPAL) to unlock your account.', e.message
		end
	end

	def test_initialization
		e = assert_raises(ArgumentError) do
			OpalCardApi.new
		end
		assert_equal 'No username provided', e.message

		e = assert_raises(ArgumentError) do
			OpalCardApi.new username: 'test'
		end
		assert_equal 'No password provided', e.message

		assert OpalCardApi.new username: 'test', password: 'test'

		ENV['OPAL_USERNAME'] = 'test'
		e = assert_raises(ArgumentError) do
			OpalCardApi.new
		end
		assert_equal 'No password provided', e.message

		ENV['OPAL_PASSWORD'] = 'test'
		assert OpalCardApi.new
	end

	# def test_identify_card_index
	# end

	def test_cards
		VCR.use_cassette('cards') do
			client = OpalCardApi.new username: 'test', password: 'test'
			cards = client.cards

			assert_equal 1, cards.size
			assert_equal '3083857629546364', cards.first['cardNumber']
		end
	end

	def test_transactions
		VCR.use_cassette('transactions') do
			client = OpalCardApi.new username: 'test', password: 'test'
			transactions = client.transactions
			transactions.take 25
		end
	end

end
