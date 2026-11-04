# frozen_string_literal: true

module PolicyOcr
  # One scanned entry: three glyph rows (the 4th, blank row is dropped).
  # Responsible for slicing rows into glyphs and turning them into a PolicyNumber.
  class Entry
    def initialize(lines)
      @rows = Array.new(Digits::HEIGHT) { |i| lines[i].to_s }
    end

    def to_policy_number
      PolicyNumber.new(digits.map { |digit| Digits.recognize(digit) }.join)
    end

    private

    attr_reader :rows

    def digits
      (0...PolicyNumber::LENGTH).map { |position| digit_at(position) }
    end

    def digit_at(position)
      rows.map { |row| segments(row).fetch(position, Digits::BLANK) }.join
    end

    def segments(row)
      @segments ||= {}
      @segments[row] ||= row.chars.each_slice(Digits::WIDTH).map(&:join)
    end
  end
end

