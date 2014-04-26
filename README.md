# Spree Moolah Payment

This is an unofficial Spree Commerce [Moolah](https://moolah.io) extension. 

Behind-the-scenes, this extension uses my [Moolah Ruby SDK](https://github.com/cloudrck/moolah-ruby).

## ToDo
1. Error Handling
2. Handle underpayed balance

## Installation

1. Add this extension to your Gemfile with this line:

        gem 'moolah-ruby', :git => 'https://github.com/cloudrck/moolah-ruby.git', :branch => 'master'
        gem 'spree_moolah_payment', :git => 'https://github.com/cloudrck/spree_moolah_payment.git', :branch => 'master'


The `branch` option is important: it must match the version of Spree you're using. Use 2-2-stable if you're using Spree 2-2-stable or any 2.2.x version. But as of now the master is the only branch, and it's running 2.2 Stable

2. Install the gem using Bundler:

        bundle install

3. Copy & run migrations

        bundle exec rails g spree_moolah_payment:install

4. Restart your server

If your server was running, restart it so that it can find the assets properly.

### Setup
1. Editing Payment => Method Moolah 
2. Enter your GUID for each coin, the GUID can be found in your Moolah control panel
3. Create config/moolah.yml, place your IPN_Secret

```
production:
    ipn  : <YOUR_IPN>

```
