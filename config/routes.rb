Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  get "/moolah/:curr" => "moolah#page", :as => :moolah_page
  get "/moolah/success" => "moolah#success", :as => :moolah_success
  get "/moolah/callback" => "moolah#callback", :as => :moolah_callback
end
