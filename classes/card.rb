# frozen_string_literal: true

class Card
  attr_reader :suit, :number

  SUITS   = %w[diamond club heart spade].freeze
  NUMBERS = Set.new(1..13)

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
    [@suit, @number].to_s
  end
end
