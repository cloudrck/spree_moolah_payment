require 'moolah'

module Spree
  class MoolahController < StoreController
    protect_from_forgery :except => :callback

    def page
    	order = current_order || raise(ActiveRecord::RecordNotFound)
    	cypto_curr =params[:curr]

	begin
        #button_name = Spree.t("button.name", :scope => :moolah, :site_name => Spree::Config.site_name, :order_number => order.number)
       case cypto_curr
              when "BTC"
              	  coin = payment_method.preferred_btc_guid
              when "LTC"
              	  coin = payment_method.preferred_ltc_guid
              when "DOGE"
              	  coin = payment_method.preferred_doge_guid
              when "VTC"
              	  coin = payment_method.preferred_vtc_guid
              when "AUR"
              	  coin = payment_method.preferred_aur_guid
              when "DRK"
              	  coin = payment_method.preferred_drk_guid
              when "MAX"
              	  coin = payment_method.preferred_max_guid
              when "MINT"
              	  coin = payment_method.preferred_mint_guid
            end
            #Generate API Request for Moolah Payment URL
            moolah_options = { :query => {
            :guid => coin,
            :currency => order.currency,
            :amount => order.total,
            :product => "Order No #{order.number}", #order id
            :return=> moolah_success_url,
            :ipn=> moolah_callback_url       
          }}

        response = moolah.generate_url_payment(moolah_options) #Execute
        
        	# ## Add a "processing" payment that is used to verify the callback
        	payment = order.payments.create({:amount => order.total,
        			:source => Spree::MoolahCheckout.create({
							:order_id => order.number,
							:status => "processing",
							:transaction_id => response['tx']
					}),
        			:payment_method => payment_method })
        	payment.started_processing!
        	###
        redirect_to "https://moolah.io/api/tx/#{response['tx']}"
        #redirect_to "#{response}"
        #For Production use
      #rescue => e
        #Rails.logger.error e
        # Redirect back to checkout so buyer can choose alternative payment method
        #redirect_to checkout_state_path(order.state)
      end
    end

    def success
    order = current_order
      flash.notice = Spree.t(:order_processed_successfully)
      flash[:commerce_tracking] = "nothing special"
      redirect_to order_path(order, :token => order.token)
    end

    def callback
    	#ToDo: Verify callback via MoolahIPN
    	# Since Moolah doesn't return any extra params, we have to relate the 'transactionID' to a customer 'order_id'
    	#
    	if ENV["ipn"] != params[:ipn_secret]
    		render text: "Invalid secret token", status: 400
    		return
    	end
   	tx_number = params[:tx]
    	tx = Spree::MoolahCheckout.find_by(:transaction_id => tx_number)
    	order= Spree::Order.find_by_number( tx.order_id)
    	@payment = order.payments.where(:state => "processing",
                                     :payment_method_id => tx.id).first
    	raise "Callback rejected: unrecognized order" unless order
    	case params[:status]
    	when "complete"
    		@payment.pend!
    		order.next
    		#callback_success(order)
    		render :text => "Callback successful"
    		@payment.complete!
    		order.update!
    	end
    	# TODO: handle mispaid amount

    	render :text => ""

    end

	private

		def payment_method
			@payment_method ||= Spree::PaymentMethod.find_by(:type => "Spree::Gateway::MoolahPayment")
		end

		def moolah
			payment_method.provider
		end

		def callback_success(order)
			
			order.payments.create!({
					:source => Spree::MoolahCheckout.create({
							:status => params[:status],
							:transaction_id => params[:tx]
					}),
					:amount => order.total,
					:payment_method => payment_method
			})
			order.next
		end
	end
end
