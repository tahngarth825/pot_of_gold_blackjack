# frozen_string_literal: true

require_relative 'card'

# NOTE: No one should be able to see the exact cards left
class Deck
  def initialize
    @cards = Card.all
  end

  def draw
    raise 'Deck empty!' if @cards.blank?

    @cards.pop
  end
end
