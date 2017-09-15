# Huginn Xero Agent

<img src="https://www.xero.com/content/dam/xero/images/opengraph/opengraph-xero.png" height=150px>

## Installation

Add this string to your Huginn's .env `ADDITIONAL_GEMS` configuration:

```ruby
ADDITIONAL_GEMS=huginn_xero_agent
```

And then execute:

    $ bundle

## Adding to your Huginn instance

<img src="https://raw.github.com/huginn/huginn/master/media/huginn-logo.png?s=100" height=100px>

Since you'll need a personal Xero application to authorize API access, visit https://app.xero.com and register a new private application. You'll need a X509 Public Key Certificate, which you can generate like this:

```shell
openssl genrsa -out privatekey.pem 1024
openssl req -new -x509 -key privatekey.pem -out publickey.cer -days 1825
```

Now copy publickey.cer and paste it in to the web UI.

You'll be given consumer key and secret, which you should put into the .env file of your Huginn instance along with the path to your private key:

```
ADDITIONAL_GEMS=huginn_xero_agent
XERO_CONSUMER_KEY=HCJI7Q...
XERO_CONSUMER_SECRET=PHOD...
XERO_PRIVATE_KEY_PATH=/path/to/your/privatekey.pem
```

## Development

Running `rake` will clone and set up Huginn in `spec/huginn` to run the specs of the Gem in Huginn as if they would be build-in Agents. The desired Huginn repository and branch can be modified in the `Rakefile`:

```ruby
HuginnAgent.load_tasks(branch: '<your branch>', remote: 'https://github.com/<github user>/huginn.git')
```

Make sure to delete the `spec/huginn` directory and re-run `rake` after changing the `remote` to update the Huginn source code.

After the setup is done `rake spec` will only run the tests, without cloning the Huginn source again.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/cantino/huginn_xero_agent/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
