require "WoC_classifier"

describe WoCClassifier::AdoptionExtractor, "#extract" do
  it "fails to extract for invalid input" do
    myextractor = WoCClassifier::AdoptionExtractor.new(File.expand_path("../data/testlist", __FILE__), File.expand_path("../data/", __FILE__), 2)
    myextractor.should_not be_nil
    myextractor.extract_all
  end
end

describe WoCClassifier::MedianChurnExtractor, "#extract" do
  it "fails to extract for invalid input" do
    myextractor = WoCClassifier::MedianChurnExtractor.new(File.expand_path("../data/testlist", __FILE__), File.expand_path("../data/", __FILE__), 2)
    myextractor.should_not be_nil
    myextractor.extract_all
  end
end

describe WoCClassifier::MonthlyChurnExtractor, "#extract" do
  it "fails to extract for invalid input" do
    myextractor = WoCClassifier::MonthlyChurnExtractor.new(File.expand_path("../data/testlist", __FILE__), File.expand_path("../data/", __FILE__), 2)
    myextractor.should_not be_nil
    myextractor.extract_all
  end
end

describe WoCClassifier::MedianCouplingExtractor, "#extract" do
  it "fails to extract for invalid input" do
    myextractor = WoCClassifier::MedianCouplingExtractor.new(File.expand_path("../data/testlist", __FILE__), File.expand_path("../data/", __FILE__), 2)
    myextractor.should_not be_nil
    myextractor.extract_all
  end
end


describe WoCClassifier::MonthlyCouplingExtractor, "#extract" do
  it "fails to extract for invalid input" do
    myextractor = WoCClassifier::MonthlyCouplingExtractor.new(File.expand_path("../data/testlist", __FILE__), File.expand_path("../data/", __FILE__))
    myextractor.should_not be_nil
    myextractor.extract_all
  end
end

describe WoCClassifier::OverviewExtractor, "#extract" do
  it "fails to extract for invalid input" do
    myextractor = WoCClassifier::OverviewExtractor.new(File.expand_path("../data/testlist", __FILE__), File.expand_path("../data/", __FILE__), 2)
    myextractor.should_not be_nil
    myextractor.extract_all
  end
end
