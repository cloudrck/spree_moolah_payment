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
              	  coin = ENV["btc"]
              when "LTC"
              	  coin = ENV["ltc"]
              when "DOGE"
              	  coin = ENV["doge"]
              when "VTC"
              	  coin = ENV["vtc"]
              when "AUR"
              	  coin = ENV["aur"]
              when "DRK"
              	  coin = ENV["drk"]
              when "MAX"
              	  coin = ENV["max"]
              when "MINT"
              	  coin = ENV["mint"]
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
							:transaction_id => response['tx']
					}),
        			:payment_method => payment_method })
        	payment.started_processing!
        	###
        #redirect_to "#{response['url']}"
        redirect_to "#{response}"
        #For Production use
      #rescue => e
        #Rails.logger.error e
        # Redirect back to checkout so buyer can choose alternative payment method
        #redirect_to checkout_state_path(order.state)
      end
    end

    def success
      flash.notice = Spree.t(:order_processed_successfully)
      flash[:commerce_tracking] = "nothing special"
      redirect_to order_path(params[:order][:custom], :moolah_id => params[:order][:id])
    end

    def callback
    	#ToDo: Verify callback via MoolahIPN
    	# Since Moolah doesn't return any extra params, we have to relate the 'transactionID' to a customer 'order_id'
    	#
    	if params[:ipn_secret] ==ENV["ipn"]
    		tx_number = params[:tx]
    		tx = Spree::MoolahCheckout.find_by(:transaction_id => tx_number)
      
    		order= Order.find_by(:number => tx.order_id)

    		raise "Callback rejected: unrecognized order" unless order

    		case params[:status]
    		when "complete"
    			callback_success(order)
    		end
    		# TODO: handle mispaid amount

    		render :text => ""
    	end
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
