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

            moolah_options = { :query => {
            :guid => coin,
            :currency => "USD",
            :amount => order.total,
            :product => "Order No #{order.number}", #order id
            :return=> moolah_success_url
            
          }}

        response = moolah.generate_url_payment(moolah_options) #Execute
        
        #redirect_to "#{response['url']}"
        redirect_to "#{response}"
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
      order_number = params[:order][:custom]
      order = Order.find_by(:number => order_number)

      raise "Callback rejected: unrecognized order" unless order

      case params[:order][:status]
      when "completed"
        callback_success(order)
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
							:moolah_id => params[:order][:id],
							:status => params[:order][:status],
							:btc_cents => params[:order][:total_btc][:cents],
							:receive_address => params[:order][:receive_address]
					}),
					:amount => order.total,
					:payment_method => payment_method
			})
			order.next
		end
	end
end
