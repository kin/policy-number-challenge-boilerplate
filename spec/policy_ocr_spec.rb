# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require_relative "../lib/policy_ocr"

RSpec.describe PolicyOcr do
  let(:sample) { fixture("sample") }

  let(:valid_entry) do
    [
      "    _  _  _  _  _  _  _  _ ",
      "|_||_   ||_ | ||_|| || || |",
      "  | _|  | _||_||_||_||_||_|",
      "                           "
    ]
  end

  let(:illegible_entry) do
    [
      " _  _        _ XXXXXX _  _ ",
      "|_||_   |  || |XXXXXX _||_ ",
      "|_||_|  |  ||_|XXXXXX _||_|",
      "                           "
    ]
  end

  let(:error_entry) do
    [
      " _  _     _  _        _  _ ",
      "|_ |_ |_| _|  |  ||_||_||_ ",
      "|_||_|  | _|  |  |  | _| _|",
      "                           "
    ]
  end

  let(:mixed) { (valid_entry + illegible_entry + error_entry).join("\n") }

  it "loads the sample fixture" do
    expect(sample.lines.count).to eq(44)
  end

  describe ".parse" do
    it "parses a single entry" do
      ocr = [
        "    _  _     _  _  _  _  _  ",
        "  | _| _||_||_ |_   ||_||_| ",
        "  ||_  _|  | _||_|  ||_| _| ",
        "                            "
      ].join("\n")

      expect(described_class.parse(ocr).map(&:to_s)).to eq(["123456789"])
    end

    it "parses every entry in sample.txt" do
      expect(described_class.parse(sample).map(&:to_s)).to eq(
                                                             %w[000000000 111111111 222222222 333333333 444444444
           555555555 666666666 777777777 888888888 999999999 123456789]
                                                           )
    end

    it "returns PolicyNumber objects" do
      expect(described_class.parse(sample)).to all(be_a(PolicyOcr::PolicyNumber))
    end
  end

  describe ".report" do
    it "matches the exact example from the spec" do
      expect(described_class.report(mixed).lines)
        .to eq(["457508000", "86110??36 ILL", "664371495 ERR"])
    end
  end

  describe PolicyOcr::Digits do
    describe ".recognize" do
      it "reads each known glyph as its digit" do
        described_class::TABLE.each do |glyph, digit|
          expect(described_class.recognize(glyph)).to eq(digit)
        end
      end

      it "returns ? for an unknown glyph" do
        expect(described_class.recognize("XXXXXXXXX")).to eq("?")
      end
    end
  end

  describe PolicyOcr::Document do
    subject(:document) { described_class.new(sample) }

    it "splits the sample into eleven entries" do
      expect(document.entries.size).to eq(11)
    end

    it "skips groups that are entirely blank" do
      document = described_class.new(("\n" * 4) + valid_entry.join("\n"))

      expect(document.policy_numbers.map(&:to_s)).to eq(["457508000"])
    end

    it "builds from a file" do
      path = File.expand_path("fixtures/sample.txt", __dir__)
      document = described_class.from_file(path)

      expect(document.policy_numbers.size).to eq(11)
    end
  end

  describe PolicyOcr::PolicyNumber do
    let(:numbers) { PolicyOcr.parse(sample) }

    describe "#checksum" do
      it "computes the checksum for each entry in sample.txt" do
        expect(numbers.map(&:checksum))
          .to eq([0, 45, 90, 135, 180, 225, 270, 315, 360, 405, 165])
      end
    end

    describe "#valid?" do
      it "is true only when the checksum is evenly divisible by 11" do
        expect(numbers.map(&:valid?))
          .to eq([true, false, false, false, false, false, false, false, false, false, true])
      end

      it "is false for an illegible number" do
        expect(described_class.new("86110??36")).not_to be_valid
      end
    end

    describe "#status" do
      it "is :ok for a valid number" do
        expect(described_class.new("457508000").status).to eq(:ok)
      end

      it "is :error for a checksum failure" do
        expect(described_class.new("664371495").status).to eq(:error)
      end

      it "is :illegible when a digit could not be read" do
        expect(described_class.new("86110??36").status).to eq(:illegible)
      end
    end

    it "compares by value" do
      expect(described_class.new("123456789")).to eq(described_class.new("123456789"))
    end
  end

  describe PolicyOcr::Report do
    def report_for(lines)
      described_class.new(PolicyOcr.parse(lines.join("\n")))
    end

    it "leaves a valid number bare, with no status" do
      expect(report_for(valid_entry).lines).to eq(["457508000"])
    end

    it "marks a checksum failure as ERR" do
      expect(report_for(error_entry).lines).to eq(["664371495 ERR"])
    end

    it "marks an illegible number as ILL, taking priority over ERR" do
      expect(report_for(illegible_entry).lines).to eq(["86110??36 ILL"])
    end

    describe "#write" do
      it "writes one entry per line, ending in a trailing newline" do
        Dir.mktmpdir do |dir|
          path = File.join(dir, "report.txt")
          PolicyOcr.report(mixed).write(path)

          expect(File.read(path)).to eq("457508000\n86110??36 ILL\n664371495 ERR\n")
        end
      end
    end
  end
end
