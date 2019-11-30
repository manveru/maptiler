require "./maptiler"
require "easy-cli"

module Maptiler
  class CLI < Easy_CLI::CLI
    def initialize
      name "maptiler"
    end

    class Version < Easy_CLI::Command
      def initialize
        name "version"
        desc "Show maptiler commands' version"
      end

      def call(data)
        puts "maptiler #{Maptiler::VERSION}"
      end
    end

    class Geocoding < Easy_CLI::Command
      def initialize
        name "geocoding"
        desc "Fetch GeoJSON from https://cloud.maptiler.com/"

        argument "query"

        key = ENV["MAPTILER_API_KEY"]?
        option "key", :string, "-k", "--key",
          default: key,
          required: key == nil,
          desc: "Set the API key (also via MAPTILER_API_KEY env var)"

        option "language", :array, "-l", "--language",
          desc: "Preferred languages (en,de)"

        option "bbox", :array, "-b", "--bbox",
               desc: "Search only within the specified bounds minx,miny,maxx,maxy"

        option "proximity", :array, "-p", "--proximity",
               desc: "Prefer results closer to the specified point lon,lat"
      end

      def call(data)
        key = data["key"].as(String)
        language = data["language"]?.as?(Array(String))
        bbox_raw = data["bbox"]?.as?(Array(String))
        bbox = bbox_raw.try{ |v| Maptiler::Geocoding::BBox.from v.map(&.to_f64) }
        proximity_raw = data["proximity"]?.as?(Array(String))
        proximity = proximity_raw.try{ |v| Maptiler::Geocoding::Proximity.from v.map(&.to_f64) }

        geocoding = Maptiler::Geocoding.new(
          key: key,
          language: language,
          bbox: bbox,
          proximity: proximity
        )

        geocoding.get(data["query"].as(String)).try do |result|
          puts result.to_json
        end
      end
    end
  end
end

cli = Maptiler::CLI.new
cli.register Maptiler::CLI::Geocoding.new
cli.register Maptiler::CLI::Version.new
cli.run(ARGV)
