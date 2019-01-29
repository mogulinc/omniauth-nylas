require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Nylas < OmniAuth::Strategies::OAuth2
      option :name, "nylas"
      option :state_delimiter, nil

      option :client_options, {
        :site          => "https://api.nylas.com",
        :authorize_url => "/oauth/authorize",
        :token_url     => "/oauth/token"
      }

      uid { access_token.params["account_id"] }

      info do
        {
          "account_id" => access_token.params["account_id"],
          "email"      => access_token.params["email_address"],
          "provider"   => access_token.params["provider"]
        }
      end

      def authorize_params
        options.authorize_params[:state] = [session["omniauth.state.prefix"], options[:state_delimiter], SecureRandom.hex(24)].compact.join("")
        params = options.authorize_params.merge(options_for("authorize"))
        if OmniAuth.config.test_mode
          @env ||= {}
          @env["rack.session"] ||= {}
        end
        session["omniauth.state"] = params[:state]
        params
      end

      def callback_phase
        session["omniauth.state.prefix"] = request.params["state"].split(options.state_delimiter).first unless options.state_delimiter.nil?
        super
      end
    end
  end
end
