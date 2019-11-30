require "./spec_helper"

describe Maptiler::Geocoding do
  it "creates simple URLs" do
    maptiler = Maptiler::Geocoding.new(key: "dummy")
    maptiler.prepare("Xanadu").to_s.
      should eq("https://api.maptiler.com/geocoding/Xanadu.json?key=dummy")
  end

  it "creates URLs with special characters" do
    maptiler = Maptiler::Geocoding.new(key: "dummy")
    maptiler.prepare("Mühlviertel, Österreich").to_s.
      should eq("https://api.maptiler.com/geocoding/M%C3%BChlviertel,%20%C3%96sterreich.json?key=dummy")
  end

  it "creates URLs with bounding box" do
    maptiler = Maptiler::Geocoding.new(key: "dummy")
    maptiler.prepare("Wien", bbox: {5.9559,45.818,10.4921,47.8084}).to_s.
      should eq("https://api.maptiler.com/geocoding/Wien.json?bbox=5.9559%2C45.818%2C10.4921%2C47.8084&key=dummy")
  end

  it "creates URLs with proximity" do
    maptiler = Maptiler::Geocoding.new(key: "dummy")
    maptiler.prepare("Wien", proximity: {5.9559,45.818}).to_s.
      should eq("https://api.maptiler.com/geocoding/Wien.json?proximity=5.9559%2C45.818&key=dummy")
  end

  it "creates URLs with language" do
    maptiler = Maptiler::Geocoding.new(key: "dummy")
    maptiler.prepare("Wien", proximity: {5.9559,45.818}).to_s.
      should eq("https://api.maptiler.com/geocoding/Wien.json?proximity=5.9559%2C45.818&key=dummy")
  end

  it "default for language can be set" do
    maptiler = Maptiler::Geocoding.new(key: "dummy", language: ["en"])
    maptiler.prepare("Wien", proximity: {5.9559,45.818}).to_s.
      should eq("https://api.maptiler.com/geocoding/Wien.json?language=en&proximity=5.9559%2C45.818&key=dummy")
  end

  it "default for language can be overruled" do
    maptiler = Maptiler::Geocoding.new(key: "dummy", language: ["en"])
    maptiler.prepare("Wien", language: ["de"]).to_s.
      should eq("https://api.maptiler.com/geocoding/Wien.json?language=de&key=dummy")
  end
end
