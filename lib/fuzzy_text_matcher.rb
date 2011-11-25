# FuzzyTextMatcher is a simplified version of jamis' FuzzyFileFinder (https://github.com/jamis/fuzzy_file_finder), 
# which is itself an implementation of TextMate's "cmd-T" functionality. 
# FuzzyTextMatcher looks for non-contiguous pattern matches against a given list of strings.
# 
# Usage:
# 
#   matcher = FuzzyTextMatcher.new(["United States", "Canada", "Mexico", "Honduras"])
#   matcher.search("us") do |match|
#     puts "[%5d] %s" % [match[:score] * 10000, match[:highlighted_name]]
#   end
#
# See Readme.rdoc or the examples directory for more.

class FuzzyTextMatcher

  # Used internally to represent a run of characters within a match. This is used to 
  # build the highlighted version of a file name.
  class CharacterRun < Struct.new(:string, :inside)
    def to_s
      if inside
        "(#{string})"
      else
        string
      end
    end
  end

  # The list of terms to search through.
  attr_reader :dictionary

  # Initializes a new FuzzyTextMatcher with the given terms as the dictionary
  def initialize(dictionary)
    @dictionary = dictionary
  end

  # Takes the given pattern (which must be a string) and searches the dictionary for matches.
  # The match is done a la cmd+T in TextMate, so "US" will match Russia, United States, and Uzbekistan.
  #
  # Each yielded match will be a hash containing the following keys:
  # * :name refers to the name of the matched term in the dictionary
  # * :highlighted_name refers to the name of the matched term with matches highlighted in parentheses
  # * :score refers to a value between 0 and 1 indicating how closely the file matches the given pattern. 
  # A score of 1 means the pattern matches the file exactly.
  def search(pattern, &block)
    regex = make_fuzzy_search_regex(pattern)

    dictionary.each do |entry|
      match_entry(entry, regex, &block)
    end
  end

  # Takes the given pattern (which must be a string, formatted as described in #search), and returns up to 
  # max matches in an array. If max is nil, all matches will be returned.
  def find(pattern, max=nil)
    results = []
    search(pattern) do |match|
      results << match
      break if max && results.length >= max
    end
    results
  end

  # Displays the finder object in a sane, non-explosive manner.
  def inspect #:nodoc:
    "#<%s:0x%x dictionary=%d>" % [self.class.name, object_id, dictionary.length]
  end

  private

  # Takes the given pattern string "foo" and converts it to a new string 
  # "(f)([^/]*?)(o)([^/]*?)(o)" 
  # that can be used to create a regular expression.
  def make_fuzzy_search_regex(pattern)
    pattern_chars = pattern.split(//)
    pattern_chars << "" if pattern.empty?
    
    pattern_regex_raw = pattern_chars.inject("") do |regex, character|
      regex << "([^/]*?)" if regex.length > 0
      regex << "(" << Regexp.escape(character) << ")"
    end
    
    regex_raw = "^(.*?)" << pattern_regex_raw << "(.*)$"
    Regexp.new(regex_raw, Regexp::IGNORECASE)
  end
  
  # TODO document
  def calculate_score(entry, runs)
    
    
    # Determine the score of this match.
    # 1. fewer "inside runs" (runs corresponding to the original pattern)
    #    is better.
    # 2. better coverage of the actual path name is better

    inside_runs = runs.select { |r| r.inside }
    inside_chars = inside_runs.inject(0) { |sum, run| sum + run.string.length }
    total_chars = runs.inject(0) { |sum, run| sum + run.string.length }
    
    run_ratio = inside_runs.length.zero? ? 1 : 1 / inside_runs.length.to_f
    char_ratio = total_chars.zero? ? 1 : inside_chars.to_f / total_chars

    score = run_ratio * char_ratio
  end
  

  # Given a MatchData object match, compute both the match score and the highlighted match string. 
  def build_match_result(match)
    runs = []
    match.captures.each_with_index do |capture, index|
      if capture.length > 0
        # Odd-numbered captures are matches inside the pattern.
        # Even-numbered captures are matches between the pattern's elements.
        inside = index % 2 != 0

        if runs.last && runs.last.inside == inside
          runs.last.string << capture
        else
          runs << CharacterRun.new(capture, inside)
        end
      end
    end
    
    score = calculate_score(match.string, runs)
    return { :score => score, :runs => runs }
  end

  # Match entry against the regex. If it matches, yield the match metadata to the block.
  def match_entry(entry, regex, &block)
    if match = entry.match(regex)
      match_result = build_match_result(match)

      result = { :name => entry,
                 :highlighted_name => match_result[:runs].join,
                 :runs => match_result[:runs],
                 :score => match_result[:score] 
               }
      yield result
    end
  end
end
