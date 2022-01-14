# frozen_string_literal: true

require_relative 'deck'

class Game
  def self.start
    new.start
  end

  def initialize
    @deck = Deck.new
  end

  def start
    while card = @deck.draw
      puts card
    end
  end
end
