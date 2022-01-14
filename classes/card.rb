# frozen_string_literal: true

class Card
  attr_reader :suit, :number

  SUITS   = %w[diamond club heart spade].freeze
  NUMBERS = %w[A 2 3 4 5 6 7 8 9 10 J Q K].to_set.freeze

  def self.all(random: true)
    result = []

    SUITS.each do |s|
      NUMBERS.each do |n|
        result << new(s, n)
      end
    end

    random ? result.shuffle : result
  end

  def initialize(suit, number)
    @suit = suit
    @number = number
  end

  def to_s
    "#{@number} of #{@suit}"
  end
end
