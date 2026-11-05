# frozen_string_literal: true

module PolicyOcr
  class Document
    LINES_PER_ENTRY = 4

    def self.from_file(path)
      new(File.read(path))
    end

    def initialize(text)
      @text = text
    end

    def entries
      @entries ||= line_groups.map { |lines| Entry.new(lines) }
    end

    def policy_numbers
      @policy_numbers ||= entries.map(&:to_policy_number)
    end

    private

    def line_groups
      @text.split("\n", -1)
           .each_slice(LINES_PER_ENTRY)
           .reject { |group| group.all? { |line| line.strip.empty? } }
    end
  end
end
