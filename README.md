# WoCClassifier

This ruby gem provides the scripts we use to classify and extract build
activity data from the World of Code dataset.

## Installation

Add this line to your application's Gemfile:

    gem 'WoC_classifier'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install WoC_classifier

## Usage

Add this line to your Ruby application:

    require 'WoC_classifier'

and you will have access to our set of extractors/classifiers. For example,
to extract all adoption data, use the AdoptionExtractor as follows:

    myextractor = WoCClassifier::AdoptionExtractor.new("mylistfile.txt")
    myextractor.extract_all

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
