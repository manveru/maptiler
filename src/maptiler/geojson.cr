require "json"

module Maptiler
  class GeoJSON
    include JSON::Serializable

    use_json_discriminator "type", {
      FeatureCollection: FeatureCollection,
    }

    class FeatureCollection
      JSON.mapping({
        features:    Array(Feature),
        type:        String,
        query:       Array(String),
        attribution: String,
      })
    end

    class Feature
      JSON.mapping({
        type:                String,
        relevance:           Float64,
        text:                String,
        center:              Array(Float64),
        context:             Array(Context)?,
        geometry:            Geometry,
        id:                  String,
        place_name:          String,
        place_type:          Array(String),
        properties:          Hash(String, JSON::Any),
        matching_place_name: String?,
        matching_text:       String?,
      })

      abstract class Geometry
        include JSON::Serializable
        use_json_discriminator "type", {
          Point:              Point,
          LineString:         LineString,
          GeometryCollection: GeometryCollection,
          MultiPoint:         MultiPoint,
          Polygon:            Polygon,
        }
      end

      class GeometryCollection < Geometry
        JSON.mapping({
          geometries: Array(Geometry),
        })
      end

      class LineString < Geometry
        JSON.mapping({
          coordinates: Array(Tuple(Float64, Float64)),
        })
      end

      class Polygon < Geometry
        JSON.mapping({
          coordinates: Array(Array(Tuple(Float64, Float64))),
        })
      end

      class MultiPoint < Geometry
        JSON.mapping({
          coordinates: Array(Tuple(Float64, Float64)),
        })
      end

      class Point < Geometry
        JSON.mapping({
          coordinates: Tuple(Float64, Float64),
        })
      end

      class Context
        JSON.mapping({
          id:     String,
          osm_id: String,
          text:   String,
        })
      end
    end

    # record Point, x : Float64, y : Float64
  end
end

#       # JSON.mapping({
#       #   geometry:   Geometry,
#       #   type:       String,
#       #   properties: Properties,
#       # })

#       class Properties
#         JSON.mapping({
#           osm_id:    String,
#           osm_type:  String?,
#           extent:    Array(Float64)?,
#           country:   String?,
#           osm_key:   String?,
#           osm_value: String?,
#           postcode:  String?,
#           name:      String?,
#           state:     String?,
#         })
#       end

#       class Geometry
#         JSON.mapping({
#           coordinates: Array(Float64),
#         })
#       end
#     end
#   end
# end
