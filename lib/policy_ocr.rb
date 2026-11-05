require_relative "policy_ocr/digits"
require_relative "policy_ocr/policy_number"
require_relative "policy_ocr/entry"
require_relative "policy_ocr/document"
require_relative "policy_ocr/report"

module PolicyOcr
  def self.parse(text)
    Document.new(text).policy_numbers
  end

  def self.report(text)
    Report.new(parse(text))
  end
end
