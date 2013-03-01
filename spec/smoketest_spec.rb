require "WoC_classifier"

describe WoCClassifier::ChurnExtractor, "#extract" do
  it "fails to extract for invalid input" do
    myextractor = WoCClassifier::ChurnExtractor.new(File.expand_path("../data/testlist", __FILE__), File.expand_path("../data/", __FILE__), 2)
    myextractor.should_not be_nil
    myextractor.extract_all
  end
end

describe WoCClassifier::CouplingExtractor, "#extract" do
  it "fails to extract for invalid input" do
    myextractor = WoCClassifier::CouplingExtractor.new(File.expand_path("../data/testlist", __FILE__), File.expand_path("../data/", __FILE__), 2)
    myextractor.should_not be_nil
    myextractor.extract_all
  end
end
