require '../lib/fuzzy_text_matcher'

# Same example as countries.rb, but showing how to deal with passed in objects using a block
# passed to the constructor that retrieves the name to use in the match.

# Example:
# $ ruby countries_as_objects.rb arq
# Looking for arq in #<FuzzyTextMatcher:0x100158a28>}
# [ 1500] M(ar)tini(q)ue #<struct CountryObject country_name="Martinique\n", country_id=2148198320>
# [  399] S(a)int Pie(r)re and Mi(q)uelon #<struct CountryObject country_name="Saint Pierre and Miquelon\n", country_id=2148194320>

# The placeholder class we will use to demonstrate objects.  Instead of passing in country names
class CountryObject < Struct.new(:country_name, :country_id)
end

# Looking for the passed-in argument in the list of countries
COUNTRIES_FILE = 'countries.txt'
# This time we create the countries list as an array of hashes...
country_list = File.open(COUNTRIES_FILE).collect { |c| CountryObject.new(c, c.object_id) }
term = ARGV[0]

# Construct the matcher, passing in the block that gets us from hash to matchable name.
matcher = FuzzyTextMatcher.new(country_list, &Proc.new { |c| c.country_name })

# Walk the results, sorting by score in descending order
puts "Looking for #{term} in #{matcher}}\n"
results = matcher.find(term).sort_by { |m| [-m[:score], m[:name]] }
results.each do |match|
  puts "[%5d] %s %s" % [match[:score] * 10000, match[:highlighted_name], match[:object].inspect]
end
