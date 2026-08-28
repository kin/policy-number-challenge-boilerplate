require "pry"

module PolicyOcr
  DIGIT_COLUMNS = 3
  ENTRY_DIGITS = 9
  ENTRY_ROWS = 4
  UNKNOWN_DIGIT = "?"

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
    parse_ocr.map do |num_str|
      num_str.chars.reverse.each_with_index.sum { |digit, index| digit.to_i * (index + 1) }
    end
  end

  def valid?
    checksum.map { |num| (num % 11).zero? }
  end

  def report
    parse_ocr.zip(valid?).map do |number, is_valid|
      if number.include?(UNKNOWN_DIGIT)
        "#{number} ILL"
      elsif !is_valid
        "#{number} ERR"
      else
        number
      end
    end
  end

  def write_report(path)
    File.write(path, report.join("\n") + "\n")
  end

  private

  def entry_groups
    lines = @ocr.split("\n", -1)
    lines.each_slice(ENTRY_ROWS).reject { |group| group.all? { |line| line.to_s.strip.empty? } }
  end

  def parse_number(entry_lines)
    rows = digit_rows(entry_lines)

    (0...ENTRY_DIGITS).map do |digit_index|
      DIGITS[cell(rows, digit_index)] || UNKNOWN_DIGIT
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
