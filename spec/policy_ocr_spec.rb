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
      let(:ocr) {[
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
      let(:file_path) {File.expand_path("fixtures/sample.txt", __dir__)}
      let(:ocr) {File.read(file_path)}

      it "parses multiple literal examples in sample.txt" do
        parser = worker_class.new(ocr)

        expect(parser.parse_ocr).to eq(%w[000000000 111111111 222222222 333333333 444444444 555555555 666666666 777777777 888888888 999999999 123456789])
      end
    end
  end
end
