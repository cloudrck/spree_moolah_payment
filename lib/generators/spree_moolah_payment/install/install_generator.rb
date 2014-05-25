module SpreeMoolahPayment
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :auto_run_migrations, :type => :boolean, :default => false
      source_root File.expand_path('../../../templates/', __FILE__)

      def copy_initializer_file
        copy_file 'spree_moolah_payment.rb', "config/initializers/spree_moolah_payment.rb"
      end

      def add_migrations
        run 'rake railties:install:migrations FROM=spree_moolah_payment'
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask 'Would you like to run the migrations now? [Y/n]')
        if run_migrations
          run 'bundle exec rake db:migrate'
        else
          puts 'Skipping rake db:migrate, don\'t forget to run it!'
        end
      end
    end
  end
end
