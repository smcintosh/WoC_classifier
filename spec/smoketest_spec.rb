require 'WoC_classifier'

describe WoCClassifier::Churn, "#extract" do
  it "fails to extract for invalid input" do
    myextractor = WoCClassifier::Churn.new("/tmp")
    myextractor.should_not be_nil
    WoCClassifier::Churn.new("/tmp").extract
  end
end
