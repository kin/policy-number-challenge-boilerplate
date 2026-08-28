require_relative '../lib/policy_ocr'
require 'pry'
require "spec_helper"

describe PolicyOcr do
  let(:worker_class) { Class.new { include PolicyOcr } }

  it "loads" do
    expect(PolicyOcr).to be_a Module
  end

  it 'loads the sample.txt' do
    expect(fixture('sample').lines.count).to eq(44)
  end

  describe "#parse_ocr" do
    context "with a single entry" do
      let!(:ocr) {[
        "    _  _     _  _  _  _  _  ",
        "  | _| _||_||_ |_   ||_||_| ",
        "  ||_  _|  | _||_|  ||_| _| ",
        "                            "
      ].join("\n")}
      it "parses single ocr literal example ('123456789')" do
        subject = worker_class.new(ocr).parse_ocr

        expect(subject).to eq(["123456789"])
      end
    end

    context "with multiple entries" do
      let!(:file_path) {File.expand_path("fixtures/sample.txt", __dir__)}
      let!(:ocr) {File.read(file_path)}

      it "parses multiple literal examples in sample.txt" do
        subject = worker_class.new(ocr)

        expect(subject.parse_ocr).to eq(%w[000000000 111111111 222222222 333333333 444444444 555555555 666666666 777777777 888888888 999999999 123456789])
      end
    end
  end

  describe "#checksum" do
    let!(:file_path) {File.expand_path("fixtures/sample.txt", __dir__)}
    let!(:ocr) {File.read(file_path)}

    context "computes the correct checksum for a range of numbers" do
      it "with multiple entries" do
        subject = worker_class.new(ocr)

        expect(subject.checksum).to eq([0, 45, 90, 135, 180, 225, 270, 315, 360, 405, 165])
      end
    end
  end

  describe "#valid?" do
    let!(:file_path) {File.expand_path("fixtures/sample.txt", __dir__)}
    let!(:ocr) {File.read(file_path)}

    it "is true when the checksum is evenly divisible by 11" do
      subject = worker_class.new(ocr)

      expect(subject.valid?).to eq([true, false, false, false, false, false, false, false, false, false, true])
    end
  end

  describe "#report" do
    it "matches the exact example from the spec" do
      content = [
        "    _  _  _  _  _  _  _  _ ",
        "|_||_   ||_ | ||_|| || || |",
        "  | _|  | _||_||_||_||_||_|",
        "                           ",
        " _  _        _ XXXXXX _  _ ",
        "|_||_   |  || |XXXXXX _||_ ",
        "|_||_|  |  ||_|XXXXXX _||_|",
        "                           ",
        " _  _     _  _        _  _ ",
        "|_ |_ |_| _|  |  ||_||_||_ ",
        "|_||_|  | _|  |  |  | _| _|",
        "                           "
      ].join("\n")

      subject = worker_class.new(content)

      expect(subject.report).to eq(["457508000", "86110??36 ILL", "664371495 ERR"])
    end

    it "marks a checksum failure as ERR" do
      content = [
        " _  _     _  _        _  _ ",
        "|_ |_ |_| _|  |  ||_||_||_ ",
        "|_||_|  | _|  |  |  | _| _|",
        "                           "
      ].join("\n")

      subject = worker_class.new(content)

      expect(subject.report).to eq(["664371495 ERR"])
    end

    it "marks an illegible number as ILL, taking priority over ERR" do
      content = [
        " _  _        _ XXXXXX _  _ ",
        "|_||_   |  || |XXXXXX _||_ ",
        "|_||_|  |  ||_|XXXXXX _||_|",
        "                           "
      ].join("\n")

      subject = worker_class.new(content)

      expect(subject.report).to eq(["86110??36 ILL"])
    end

    it "leaves a valid number bare, with no status" do
      content = [
        "    _  _  _  _  _  _  _  _ ",
        "|_||_   ||_ | ||_|| || || |",
        "  | _|  | _||_||_||_||_||_|",
        "                           "
      ].join("\n")

      subject = worker_class.new(content)

      expect(subject.report).to eq(["457508000"])
    end
  end

  describe "#write_report" do
    it "writes the report to disk, one entry per line, ending in a trailing newline" do
      content = [
        "    _  _  _  _  _  _  _  _ ",
        "|_||_   ||_ | ||_|| || || |",
        "  | _|  | _||_||_||_||_||_|",
        "                           ",
        " _  _        _ XXXXXX _  _ ",
        "|_||_   |  || |XXXXXX _||_ ",
        "|_||_|  |  ||_|XXXXXX _||_|",
        "                           ",
        " _  _     _  _        _  _ ",
        "|_ |_ |_| _|  |  ||_||_||_ ",
        "|_||_|  | _|  |  |  | _| _|",
        "                           "
      ].join("\n")

      parser = worker_class.new(content)

      Dir.mktmpdir do |dir|
        path = File.join(dir, "report.txt")
        parser.write_report(path)

        expect(File.read(path)).to eq("457508000\n86110??36 ILL\n664371495 ERR\n")
      end
    end
  end
end
