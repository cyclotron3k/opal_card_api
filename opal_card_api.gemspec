lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opal_card_api/version'

Gem::Specification.new do |spec|
	spec.name        = 'opal_card_api'
	spec.version     = OpalCardApi::VERSION
	spec.authors     = ['cyclotron3k']
	spec.email       = ['aidan.samuel@gmail.com']

	spec.summary     = 'A screen-scraper to retrieve your cards and transactions from the Opal Card website'
	spec.homepage    = 'https://github.com/cyclotron3k/opal_card_api'
	spec.license     = 'MIT'

	spec.metadata    = {
		'bug_tracker_uri'   => 'https://github.com/cyclotron3k/opal_card_api/issues',
		'changelog_uri'     => 'https://github.com/cyclotron3k/opal_card_api/blob/master/CHANGELOG.md',
		'documentation_uri' => "https://github.com/cyclotron3k/opal_card_api/blob/v#{OpalCardApi::VERSION}/README.md",
		'source_code_uri'   => 'https://github.com/cyclotron3k/opal_card_api'
	}

	spec.require_paths = ['lib']
	spec.files         = Dir.chdir(File.expand_path(__dir__)) do
		`git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
	end

	spec.add_runtime_dependency 'caching_enumerator', '~> 0.0'
	spec.add_runtime_dependency 'mechanize', '~> 2.7'
	spec.add_runtime_dependency 'tzinfo', '~> 2.0'

	spec.add_development_dependency 'bundler-audit', '~> 0.6'
	spec.add_development_dependency 'minitest', '~> 5.0'
	spec.add_development_dependency 'pry', '~> 0.12'
	spec.add_development_dependency 'rake', '~> 12.3.3'
	spec.add_development_dependency 'rubocop', '~> 0.71'
	spec.add_development_dependency 'vcr', '~> 4.0'
	spec.add_development_dependency 'webmock', '~> 3.5'

	spec.required_ruby_version = '~> 2.3'
end
