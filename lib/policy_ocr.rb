require "pry"

module PolicyOcr
  DIGIT_COLUMNS = 3
  ENTRY_DIGITS = 9
  ENTRY_ROWS = 4

  DIGITS = {
    (" _ " +
      "| |" +
      "|_|") => 0,
    ("   " +
      "  |" +
      "  |") => 1,
    (" _ " +
      " _|" +
      "|_ ") => 2,
    (" _ " +
      " _|" +
      " _|") => 3,
    ("   " +
      "|_|" +
      "  |") => 4,
    (" _ " +
      "|_ " +
      " _|") => 5,
    (" _ " +
      "|_ " +
      "|_|") => 6,
    (" _ " +
      "  |" +
      "  |") => 7,
    (" _ " +
      "|_|" +
      "|_|") => 8,
    (" _ " +
      "|_|" +
      " _|") => 9
  }.freeze

  def initialize(ocr)
    @ocr = ocr
  end

  def parse_ocr
    entry_groups.map { |group| parse_number(group) }
  end

  def checksum
    parse_ocr.map { |num_str| num_str.to_i.digits.sum }
  end

  def valid?
    checksum.map { |num| (num % 11).zero? }
  end

  private

  def entry_groups
    lines = @ocr.split("\n", -1)
    lines.each_slice(ENTRY_ROWS).reject { |group| group.all? { |line| line.to_s.strip.empty? } }
  end

  def parse_number(entry_lines)
    rows = digit_rows(entry_lines)

    (0...ENTRY_DIGITS).map do |digit_index|
      DIGITS[cell(rows, digit_index)]
    end.join
  end

  def digit_rows(entry_lines)
    Array.new(3) do |i|
      (entry_lines[i] || "").chars.each_slice(DIGIT_COLUMNS).map(&:join)
    end
  end

  def cell(rows, digit_index)
    rows.map do |digit|
      digit.fetch(digit_index) { " " * DIGIT_COLUMNS }
    end.join
  end
end
