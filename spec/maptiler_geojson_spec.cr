require "./spec_helper"

describe Maptiler::GeoJSON do
  it "Maps JSON to GeoJSON (Tokyo)" do
    json = Maptiler::GeoJSON.from_json(File.read("spec/fixtures/Tokyo.json"))
    json.query.should eq(["tokyo"])
    json.type.should eq("FeatureCollection")
    json.attribution.should eq(%(<a href="https://www.maptiler.com/copyright/" target="_blank">&copy; MapTiler</a> <a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap contributors</a>))
    json.features.size.should eq(6)
    json.features.first.type.should eq("Feature")
    json.features.first.center.should eq([139.2947745, 34.2255804])
  end

  it "Maps JSON to GeoJSON (Munich)" do
    json = Maptiler::GeoJSON.from_json(File.read("spec/fixtures/München.json"))
    json.query.should eq(["münchen"])
    json.type.should eq("FeatureCollection")
    json.attribution.should eq(%(<a href="https://www.maptiler.com/copyright/" target="_blank">&copy; MapTiler</a> <a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap contributors</a>))
    json.features.size.should eq(10)

    hirschbach = json.features.first
    hirschbach.type.should eq("Feature")
    hirschbach.center.should eq([11.5807909, 49.5560714])
    hirschbach.context.not_nil!.first.id.should eq("city.1028543")
    hirschbach.context.not_nil!.first.id.should eq("city.1028543")
    hirschbach.geometry.as(Maptiler::GeoJSON::Feature::Point).coordinates.should eq({11.5807909, 49.5560714})
    hirschbach.id.should eq("subcity.333153731")
    hirschbach.place_name.should eq("München, Hirschbach, Upper Palatinate, Bavaria")
    hirschbach.place_type.should eq(["subcity"])
    hirschbach.properties.should eq({"osm_id" => "node333153731"})
    hirschbach.text.should eq("München")
    hirschbach.relevance.should eq(1)

    munich = json.features[4]
    munich.matching_place_name.should eq("München, Upper Bavaria, Bavaria")
    munich.matching_text.should eq("München")
  end
end
