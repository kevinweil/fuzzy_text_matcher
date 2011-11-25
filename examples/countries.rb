require '../lib/fuzzy_text_matcher'

# Example:
# $ ruby countries.rb arq
# Looking for arq in #<FuzzyTextMatcher:0x10015c308>}
# [ 1500] M(ar)tini(q)ue
# [  399] S(a)int Pie(r)re and Mi(q)uelon

# Looking for the passed-in argument in the list of countries
COUNTRIES_FILE = 'countries.txt'
country_list = File.open(COUNTRIES_FILE).collect { |c| c.strip }
term = ARGV[0]

# Construct the matcher
matcher = FuzzyTextMatcher.new(country_list)

# Walk the results, sorting by score in descending order
puts "Looking for #{term} in #{matcher}}\n"
results = matcher.find(term).sort_by { |m| [-m[:score], m[:name]] }
results.each do |match|
  puts "[%5d] %s" % [match[:score] * 10000, match[:highlighted_name]]
end
