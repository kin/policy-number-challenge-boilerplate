require_relative '../lib/policy_ocr'

describe PolicyOcr do
  it "loads" do
    expect(PolicyOcr).to be_a Module
  end

  it 'loads the sample.txt' do
    expect(fixture('sample').lines.count).to eq(44)
  end

  describe '.parse' do
    let(:sample_numbers) do
      %w[
        000000000 111111111 222222222 333333333 444444444 555555555
        666666666 777777777 888888888 999999999 123456789
      ]
    end

    it 'parses every entry in the sample file' do
      expect(PolicyOcr.parse(fixture('sample'))).to eq(sample_numbers)
    end

    context 'when trailing whitespace has been stripped' do
      let(:text) { fixture('sample').lines.map(&:rstrip).join("\n") }

      it 'still parses every entry' do
        expect(PolicyOcr.parse(text)).to eq(sample_numbers)
      end
    end

    context 'when the last entry has no blank line after it' do
      let(:text) { fixture('sample').lines[0...-1].join }

      it 'still parses every entry' do
        expect(PolicyOcr.parse(text)).to eq(sample_numbers)
      end
    end

    context 'when the file ends with extra blank lines' do
      let(:text) { fixture('sample') + "\n\n" }

      it 'ignores them' do
        expect(PolicyOcr.parse(text)).to eq(sample_numbers)
      end
    end

    context 'when a digit is not recognized' do
      let(:text) do
        " _  _  _  _  _  _  _  _  _ \n" \
        "| || || || || || || || || |\n" \
        "|_||_||_||_||_||_||_||_||_ \n" \
        "                           \n"
      end

      it 'raises InvalidDigit' do
        expect { PolicyOcr.parse(text) }.to raise_error(PolicyOcr::InvalidDigit)
      end
    end
  end

  describe '.parse_file' do
    let(:path) { File.join(__dir__, 'fixtures', 'sample.txt') }

    it 'parses the file at the given path' do
      expect(PolicyOcr.parse_file(path)).to eq(PolicyOcr.parse(fixture('sample')))
    end
  end
end
