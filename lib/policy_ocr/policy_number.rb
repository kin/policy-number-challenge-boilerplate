# frozen_string_literal: true

module PolicyOcr
  class PolicyNumber
    LENGTH = 9

    attr_reader :digits

    def initialize(digits)
      @digits = digits.to_s.freeze
    end

    def legible?
      !digits.include?(Digits::UNKNOWN)
    end

    def checksum
      digits.chars.reverse.each_with_index.sum { |digit, i| digit.to_i * (i + 1) }
    end

    def valid?
      legible? && (checksum % 11).zero?
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
