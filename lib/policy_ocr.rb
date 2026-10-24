module PolicyOcr
  class InvalidDigit < StandardError; end

  LINES_PER_ENTRY = 4
  DIGITS_PER_ENTRY = 9
  DIGIT_WIDTH = 3
  DIGIT_HEIGHT = 3
  LINE_WIDTH = DIGITS_PER_ENTRY * DIGIT_WIDTH

  DIGITS = {
    [" _ ",
     "| |",
     "|_|"] => "0",

    ["   ",
     "  |",
     "  |"] => "1",

    [" _ ",
     " _|",
     "|_ "] => "2",

    [" _ ",
     " _|",
     " _|"] => "3",

    ["   ",
     "|_|",
     "  |"] => "4",

    [" _ ",
     "|_ ",
     " _|"] => "5",

    [" _ ",
     "|_ ",
     "|_|"] => "6",

    [" _ ",
     "  |",
     "  |"] => "7",

    [" _ ",
     "|_|",
     "|_|"] => "8",

    [" _ ",
     "|_|",
     " _|"] => "9",
  }.freeze

  def self.parse_file(path)
    parse(File.read(path))
  end

  def self.parse(text)
    entries = text.lines.each_slice(LINES_PER_ENTRY)
    entries = entries.reject { |lines| blank_entry?(lines) }
    entries.map { |lines| parse_entry(lines) }
  end

  def self.parse_entry(lines)
    rows = lines.first(DIGIT_HEIGHT).map { |line| line.chomp.ljust(LINE_WIDTH) }

    digits = (0...DIGITS_PER_ENTRY).map do |position|
      start = position * DIGIT_WIDTH
      # Cut the digit's 3-column slice out of each row
      symbol = rows.map { |row| row[start, DIGIT_WIDTH] }
      parse_digit(symbol)
    end

    digits.join
  end

  def self.parse_digit(symbol)
    DIGITS.fetch(symbol) { raise InvalidDigit, "unrecognized digit:\n#{symbol.join("\n")}" }
  end

  def self.blank_entry?(lines)
    lines.all? { |line| line.strip.empty? }
  end

  private_class_method :parse_entry, :parse_digit, :blank_entry?
end
