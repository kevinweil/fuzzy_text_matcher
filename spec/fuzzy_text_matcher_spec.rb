require File.dirname(__FILE__) + '/spec_helper'

describe FuzzyTextMatcher do
  before do
    @@TEST_COUNTRIES = ["United States", "Canada", "Russia", "Mexico", "Argentina", "Brazil", "Belize"]
    @matcher = FuzzyTextMatcher.new(@@TEST_COUNTRIES)
  end

  it "finds two countries for US" do
    @matcher.find("US").should have(2).items
  end

  it "is case-insensitive" do
    @matcher.find("US").should == @matcher.find("us")
  end

  it "finds the two countries with Z" do
    countries_with_z = @matcher.find("z").collect { |m| m[:name] }.compact
    countries_with_z.should == ["Brazil", "Belize"]
  end

  it "should rank consecutive runs higher than separated characters" do
    countries_with_ta = @matcher.find("at")
    usa = countries_with_ta.select { |m| m[:name] == "United States" }.first
    argentina = countries_with_ta.select { |m| m[:name] == "Argentina" }.first
    usa[:score].should be > argentina[:score]
  end

  it "should return no results when given an empty or nil argument" do
    @matcher.find("").should be_empty
    @matcher.find(nil).should be_empty
  end

  it "should return a 1.0 score for an exact match" do
    results = @matcher.find("United States")
    results.should have(1).items
    results[0][:score].should == 1.0
  end

  it "should construct the regex properly" do
    # Hack to test a private method.
    def @matcher.make_fuzzy_search_regex_public(*args)
      make_fuzzy_search_regex(*args)
    end
    @matcher.make_fuzzy_search_regex_public("foo").source.should == "^(.*?)(f)([^/]*?)(o)([^/]*?)(o)(.*)$"
  end

  it "works with the name retriever block" do
    class CountryObject < Struct.new(:country_name, :country_id); end
    objects = @@TEST_COUNTRIES.collect { |c| CountryObject.new(c, c.object_id) }
    object_matcher = FuzzyTextMatcher.new(objects, &Proc.new { |m| m.country_name })
    object_matcher.find("US").should have(2).items
  end
end