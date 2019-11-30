require "http/client"
require "json"
require "./maptiler/geojson"

# TODO: Write documentation for `Maptiler`
module Maptiler
  VERSION = "0.1.0"

  class Geocoding
    alias BBox = Tuple(Float64, Float64, Float64, Float64)
    alias Proximity = Tuple(Float64, Float64)
    alias Unset = Nil

    property baseURL : URI = URI.parse("https://api.maptiler.com")
    property key : String
    property bbox : BBox? = nil
    property proximity : Proximity? = nil
    property language : Array(String)? = nil

    def initialize(
         @key : String,
         @baseURL : URI = @baseURL,
         @bbox : BBox? = nil,
         @proximity : Proximity? = nil,
         @language : Array(String)? = nil
    )
    end

    def lookup(**args)
      url = prepare(**args)
      HTTP::Client.get(url)
    end

    def prepare(
      query : String,
      bbox : BBox? = nil,
      proximity : Proximity? = nil,
      language : Array(String)? = nil
    ) : URI
      url = @baseURL.dup
      params = make_params language, bbox, proximity
      params["key"] = @key
      url.query = params.to_s
      url.path = "/geocoding/#{URI.encode(query)}.json"
      url
    end

    def get(
         query : String,
         bbox : BBox? = nil,
         proximity : Proximity? = nil,
         language : Array(String)? = nil
    ) : GeoJSON | Nil
      url = prepare(query, bbox, proximity, language)
      handle_response HTTP::Client.get(url)
    end

    private def handle_response(res : HTTP::Client::Response) : GeoJSON | Nil
      case res.status
      when HTTP::Status::OK
        GeoJSON.from_json(res.body_io)
      when HTTP::Status::NOT_FOUND
        nil
      when HTTP::Status::FORBIDDEN
        raise "Make sure your API key is correct!"
      else
        raise "Unknown response: #{res.body.to_s}"
      end
    end

    private macro make_params(*names)
      HTTP::Params.new.tap do |params|
        {% for name in names %}
          if value = {{name}}
            params["{{name}}"] = value.join(",")
          elsif value = @{{name.id}}
            params["{{name}}"] = value.join(",")
          end
        {% end %}
      end
    end
  end
end
