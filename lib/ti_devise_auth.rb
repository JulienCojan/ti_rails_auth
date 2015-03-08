# encoding: utf-8

require 'rails/railtie'
require 'ti_devise_auth/grants_header_authenticable'

module TiDeviseAuth

  STRATEGY = :grants_header_authenticable

  class Railtie < Rails::Railtie
    
    config.ti_devise_auth = ActiveSupport::OrderedOptions.new
    config.ti_devise_auth.scope = :user
    config.ti_devise_auth.devise = false

    config.after_initialize do
      Warden::Strategies.add TiDeviseAuth::STRATEGY, GrantsHeaderAuthenticable
    end

    initializer "ti_devise_auth.configure_rails_initialization" do |app|
      unless app.config.ti_devise_auth.devise
        app.middleware.insert_before("ActionDispatch::ParamsParser",
                                     "Warden::Manager") do |manager|
          manager.failure_app = ->(env) { [401, {}, ['']] }
          manager.intercept_401 = false
        end
      end
    end
  end

  class Config
    def self.scope
      Rails.application.config.ti_devise_auth.scope
    end

    def self.model
      @model ||= scope.to_s.camelcase.constantize
    end
  end
end
