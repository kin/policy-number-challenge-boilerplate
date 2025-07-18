def trinaryParseNumbers(file_path)
  if File.exist?(file_path)
    input = File.read(file_path)

    encoded = input.gsub(" ", "0").gsub("_", "1").gsub("|", "2")
    
    lines = encoded.lines.map(&:chomp)
    
    chunks = lines.map { |line| line.scan(/.{3}/) }
    
    digit_values = []

    chunks[0].size.times do |i|
      top = chunks[0][i].chars.map(&:to_i)
      middle = chunks[1][i].chars.map(&:to_i)
      bottom = chunks[2][i].chars.map(&:to_i)

      # Trinary Conversion
      topWeighted = top[0] * 9 + top[1] * 3 + top[2]
      middleWeighted = middle[0] * 9 + middle[1] * 3 + middle[2]
      bottomWeighted = bottom[0] * 9 + bottom[1] * 3 + bottom[2]

      digit_values << if middleWeighted == 20
        0
      elsif topWeighted == 0 && middleWeighted == 2
        1
      elsif middleWeighted == 5
        if bottomWeighted == 21
          2
        else
          3
        end
      elsif topWeighted  == 0 && middleWeighted == 23
        4
      elsif middleWeighted == 21
        if bottomWeighted == 5
          5
        else
          6
        end
      elsif middleWeighted == 2 && bottomWeighted == 2
        7
      elsif middleWeighted == 23
        if bottomWeighted == 23
          8
        else
          9
        end
      end
    end
    digit_values
  else
    puts "Incompatible File #{file_path}"
  end
end

def arrayToString(arrayOfNumbers)
  arrayOfNumbers.join("")
end

policy_file = ARGV[0]
policy_numbers = trinaryParseNumbers(policy_file)
puts(arrayToString(policy_numbers))
