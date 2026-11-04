# frozen_string_literal: true

module PolicyOcr
  class PolicyNumber
    LENGTH = 9
    MODULUS = 11

    attr_reader :digits

    def initialize(digits)
      @digits = digits.to_s.freeze
    end

    def legible?
      !digits.include?(Digits::UNKNOWN)
    end

    # (d1 + 2*d2 + ... + 9*d9) where d1 is the rightmost digit.
    def checksum
      digits.chars.reverse.each_with_index.sum { |digit, i| digit.to_i * (i + 1) }
    end

    def valid?
      legible? && (checksum % MODULUS).zero?
    end

    def status
      return :illegible unless legible?
      return :error unless valid?

      :ok
    end

    def to_s
      digits
    end

    def ==(other)
      other.is_a?(PolicyNumber) && other.digits == digits
    end
    alias eql? ==

    def hash
      digits.hash
    end
  end
end
