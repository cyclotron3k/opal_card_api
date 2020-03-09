# OpalCardApi

[![Build Status](https://travis-ci.org/cyclotron3k/opal_card_api.svg?branch=master)](https://travis-ci.org/cyclotron3k/opal_card_api)

Do you live in Sydney? Do you have an Opal card and want to scrape your data? Then this is the gem for you.

It caches aggressively to minimize the number of "api calls".

This is a screen-scraping gem, so it is liable to stop working at any moment.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'opal_card_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install opal_card_api

## Usage

Create a new instance using named parameters:
```ruby
client = OpalCardApi.new username: 'GladysBerejiklian', password: 'TR41NL0V3R'
```

Or if you like, you can use environment variables: `OPAL_USERNAME` & `OPAL_PASSWORD`
```ruby
client = OpalCardApi.new
```

Now that you have a client, you can retrieve your cards:
```ruby
cards = client.cards
# => [{"cardNumber"=>"3083857629546364",
#   "displayCardNumber"=>nil,
#   "fareCategoryCode"=>nil,
#   "fareCategoryTitle"=>nil,
#   "cardNickName"=>"Lobster",
#   "cardState"=>"ISSUED",
#   "cardBalance"=>2307,
#   "active"=>true,
#   "svPending"=>0,
#   "toBeActivated"=>false,
#   "displayName"=>"Lobster",
#   "cardBalanceInDollars"=>"$23.07",
#   "currentCardBalanceInDollars"=>"$23.07",
#   "svPendingInDollars"=>nil}]
```

Typically you'll only have one card, and by calling `transactions` you can get all of the transactions associated with that card:
```ruby
transactions = client.transactions
```

Now, because we're screen-scraping behind the scenes, and because we probably only want the most recent transactions, `transactions` returns an `Enumerator` that only requests as many pages of transactions as required. Care must be taken to avoid downloading your entire transaction history (unless that is what you want to do).
```ruby
# GOOD
two_most_recent = transactions.take 2
# => [{:id=>1301,
#   :timestamp=>2019-06-13 18:36:00 +1000,
#   :mode=>"train",
#   :description=>"Central to Strathfield",
#   :journey_number=>7,
#   :fare_applied=>"Off-peak",
#   :fare=>"$4.40",
#   :discount=>"$1.32",
#   :amount=>"-$3.08"},
#  {:id=>1299,
#   :timestamp=>2019-06-13 08:53:00 +1000,
#   :mode=>"train",
#   :description=>"Strathfield to Central",
#   :journey_number=>6,
#   :fare_applied=>"",
#   :fare=>"$4.40",
#   :discount=>"$0.00",
#   :amount=>"-$4.40"}]

# GOOD - watch out for time zones though
transactions.take_while { |t| t[:timestamp] > Time.new(2019, 6, 11, 12, 0, 0) }

# BAD - using select like this forces every transaction to be downloaded
transactions.select { |t| t[:id] >= 1100 }

# GOOD - we can rely on the reverse chronological order of the results
transactions.take_while { |t| t[:id] >= 1100 }

# PRETTY AWESOME - using Enumerable#lazy to postpone filtering
transactions.lazy.select { |t| t[:mode] == 'train' }.first 5

# Just get all transactions:
transactions.to_a
```

Read the documentation for [Enumerable](https://ruby-doc.org/core-2.6/Enumerable.html) and [Enumerator](https://ruby-doc.org/core-2.6/Enumerator.html), to see all the things you can do with the Enumerator returned by `transactions`.

If you have more than one card you'll probably want to specify which card to retrieve transactions for. The default behaviour (as illustrated above) is to show transactions for the first card in the card array returned by `OpalCardApi#cards`.

To retrieve transactions for other cards, you must specify which one
```ruby
# By specifying the ID of the card:
client.transactions('3083857629546364')

# By specifying then name of the card:
client.transactions('Lobster')

# By specifying the index of the card:
client.transactions(3) # your fourth card

# By using one of the hashes returned by client.cards:
client.transactions(client.cards.last)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cyclotron3k/opal_card_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OpalCardApi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/cyclotron3k/opal_card_api/blob/master/CODE_OF_CONDUCT.md).
