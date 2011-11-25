require File.dirname(__FILE__) + '/spec_helper'

describe FuzzyTextMatcher do
  before do
    @@TEST_COUNTRIES = ["United States", "Canada", "Russia", "Mexico", "Argentina", "Brazil", "Belize"]
    @matcher = FuzzyTextMatcher.new(@@TEST_COUNTRIES)
  end
  
  it "finds two countries for US" do
    @matcher.find("US").should have(2).items
  end
end