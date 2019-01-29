require "spec_helper"

describe Omniauth::Nylas do
  let(:access_token) { double("AccessToken", options: {}) }
  let(:parsed_response) { double("ParsedResponse") }
  let(:response) { double("Response", parsed: parsed_response) }
  let(:request) { double('Request', params: {}, cookies: {}, env: {}) }
  let(:session) { {} }
  let(:app) do
    lambda do
      [200, {}, ['Hello.']]
    end
  end
  let(:options) { {} }

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  subject do
    OmniAuth::Strategies::Nylas.new(app, 'appid', 'secret', options).tap do |strategy|
      allow(strategy).to receive(:request) do
        request
      end

      allow(strategy).to receive(:session) do
        session
      end
    end
  end

  before(:each) do
    allow(subject).to receive(:full_host).and_return("http://example.com")
    allow(subject).to receive(:script_name).and_return("")
    allow(subject).to receive(:access_token).and_return(access_token)
    allow(subject).to receive(:query_string).and_return("")
  end

  describe "client" do
    it "should have the correct site" do
      expect(subject.client.site).to eq("https://api.nylas.com")
    end

    it "should have the correct authorize url" do
      expect(subject.client.authorize_url).to eq("https://api.nylas.com/oauth/authorize")
    end

    it "should have the correct token url" do
      expect(subject.client.token_url).to eq("https://api.nylas.com/oauth/token")
    end
  end

  describe "#callback_url" do
    it "should redirect to callback url" do
      expect(subject.callback_url).to eq("http://example.com/auth/nylas/callback")
    end
  end

  describe "#authorize_params" do
    before(:each) {
      allow(subject).to receive(:session).and_return({})
    }

    it "has the state param" do
      expect(subject.authorize_params.has_key?("state")).to eq(true)
      expect(subject.authorize_params["state"].length).to eq(48)
    end

    context "with omniauth.state.prefix" do
      before(:each) {
        allow(subject).to receive(:session).and_return({"omniauth.state.prefix" => "foobar"})
      }

      it "prefixes the state param" do
        expect(subject.authorize_params["state"]).to start_with("foobar")
      end
    end

    context "with state_delimiter set" do
      let(:options) { {state_delimiter: ":"} }

      it "adds starts with the delimiter" do
        expect(subject.authorize_params["state"]).to start_with(":")
      end
    end
  end
end
