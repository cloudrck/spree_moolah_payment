module Spree
	class Gateway::MoolahPayment < Gateway
=begin    
		preference :btc_guid, :string
		preference :ltc_guid, :string
		preference :doge_guid, :string
		preference :vtc_guid, :string
		preference :aur_guid, :string
		preference :drk_guid, :string
		preference :max_guid, :string
		preference :mint_guid, :string
		preference :ipn_secret, :string

	Future Code
   @@api_key = nil

    def self.api_key=(api_key)
        @api_key = api_key
    end

    def self.api_key(api)
    	#
    end
=end
    def supports?(source)
      true
    end

    def provider_class
      ::Moolah::Client
    end

    def provider
        #::Moolah::Client::api_key = @api_key
        provider_class.new('')
    end

    def auto_capture?
      true
    end

    def purchase(amount, moolah_checkout, gateway_options={})
      # Do nothing because all processing has been done by controller.
      # This method has to exist because auto_capture? is true.

      Class.new do
        def success?; true; end
        def authorization; nil; end
      end.new
    end

    def method_type
      'moolah'
    end

  end
end
