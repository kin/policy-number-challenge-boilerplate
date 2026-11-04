# frozen_string_literal: true

module PolicyOcr
  module Digits
    WIDTH = 3
    HEIGHT = 3
    UNKNOWN = "?"
    BLANK = (" " * WIDTH).freeze

    TABLE = {
      " _ | ||_|" => "0",
      "     |  |" => "1",
      " _  _||_ " => "2",
      " _  _| _|" => "3",
      "   |_|  |" => "4",
      " _ |_  _|" => "5",
      " _ |_ |_|" => "6",
      " _   |  |" => "7",
      " _ |_||_|" => "8",
      " _ |_| _|" => "9"
    }.freeze

    def self.recognize(digit)
      TABLE.fetch(digit, UNKNOWN)
    end
  end
end
