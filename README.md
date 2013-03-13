# OptinParsing

Automatic parsing of json and xml request bodies requires care. Beyond vulnerabilities in the parameter parsing code itself the ability for a requester to be able to control the type of parameters combines badly with some of mysql's typecasting logic, for example

    User.find_by_secret_token(0)

returns a user with a secret token that does not look to mysql like a valid integer instead of returning nil. Rails 3.2.12 contains some mitigations for this (the above example does not work on rails 3.2.12 and above) but can't catch all cases. You can avoid this by calling `to_s` on parameters that should be strings. For more details see the [security advisory](http://groups.google.com/group/rubyonrails-security/browse_thread/thread/64e747e461f98c25). It is easy to forget to do this and it goes against the philosophy of "secure by default".

An easy mitigation is to simply disable this parsing by removing mime types from `ActionDispatch::ParamsParser::DEFAULT_PARSERS` this is a change that affects all controllers. 

This gem allows the automatic parameter parsing to be turned on  per controller and per action, so that (for example) api endpoints that need to accept json and/or xml can continue to work (and be audited for their parameter usage) but reducing the surface of attack by not allowing json bodies for all those requests that do not need it.

The default is for such parsing to be disabled for all controllers.

## Installation

Add this line to your application's Gemfile:

    gem 'optin_parsing'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install optin_parsing

## Usage

Allow a controller to parse xml bodies automatically

    class MyController < ApplicationController
      parses :xml
    end

Allow a controller to parse json bodies automatically, only for a certain action

    class MyController < ApplicationController
      parses :json, :only => :some_action
    end

Allow a controller to parse json bodies automatically, except for certain actions

    class MyController < ApplicationController
      parses :json, :except => [:some_exempt_action, :another_exempt_action]
    end

Allow a controller to parse a specific mime type, with a custom strategy

    class MyController < ApplicationController
      parses Mime::YAML do |raw_post|
        #parse raw_post and return a hash of data
      end
    end

Subclasses inherit their parent classes' settings

## Caveats

Ordinarily parameters are parsed by a Rack middleware. This gem defers parsing until the request is processed by the controller: the parsed parameters will not be available to middleware code that runs before this.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
