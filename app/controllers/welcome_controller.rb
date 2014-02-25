require 'twitter'
require 'savon'
require 'net/http'
require 'uri'

class WelcomeController < ApplicationController

  def index
  end

  def tweets
    @tweets = []

    unless @client
      @client = Twitter::Streaming::Client.new do |config|
        config.consumer_key        = 'n5fWmb3fiv45x2lopRbEHw'
        config.consumer_secret     = 'w4VDHRA4BHcBdWUqDRTDG3JBk3iwdWDvf6z9W54'
        config.access_token        = '267030983-qDCnQbPVGbgmHsdVOvUAKrtxTSg78BMvbaTre7i2'
        config.access_token_secret = 'CwxHQ3ajjuxb2sFbRLzvNeVXnZfco0bjpi65BGIveLF2o'
      end
    end

    @client.sample do |object|
      unless @tweets.length < 3
        break
      end

      if object.is_a?(Twitter::Tweet) and not object['geo'].nil?
        @tweets.push(object)
      end
    end

    render json: @tweets
  end

  def translate
    unless @access_token
      refresh_token()
    end

    client = Savon.client(
        wsdl: 'http://api.microsofttranslator.com/V2/soap.svc?wsdl',
        namespace: 'http://api.microsofttranslator.com/V2',
        namespace_identifier: :v2,
        headers: {'Authorization' => "Bearer #{@access_token}"},
    )

    parameters = {
        'v2:text'        => params[:text],
        'v2:to'          => 'en',
        'v2:contentType' => 'text/plain',
        'v2:category'    => 'general',
    }

    result = client.call(:translate, message: parameters)

    render json: {
        result: result.body[:translate_response][:translate_result]
    }

  end

  def refresh_token
    require "net/http"
    require "uri"

    uri = URI.parse('https://datamarket.accesscontrol.windows.net/v2/OAuth2-13')

    response = Net::HTTP.post_form(uri, {
        'grant_type' => 'client_credentials',
        'client_id' => 'ColinDumitruTwitterTranslator',
        'client_secret' => 'rLzOnnzldvHt94OHXboAsFlvb0a5vbBmSN1/VnNwkk8=',
        'scope' => 'http://api.microsofttranslator.com'
    })

    @access_token = JSON.parse(response.body)['access_token']
  end
end
