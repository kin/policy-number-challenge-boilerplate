# frozen_string_literal: true

module PolicyOcr
  class Report
    ERROR_CODES = {
      illegible: "ILL",
      error: "ERR"
    }.freeze

    def initialize(policy_numbers)
      @policy_numbers = policy_numbers
    end

    def lines
      @policy_numbers.map { |number| format_line(number) }
    end

    def to_s
      lines.map { |line| "#{line}\n" }.join
    end

    def write(path)
      File.write(path, to_s)
    end

    private

    def format_line(number)
      code = error_code(number)
      code ? "#{number} #{code}" : number.to_s
    end

    def error_code(number)
      ERROR_CODES[number.status]
    end
  end
end
