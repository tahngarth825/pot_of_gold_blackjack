# frozen_string_literal: true

class Hand
  ROYALS = %w[J Q K].to_set.freeze

  STATES = [
    PENDING,
    FINISHED
  ].freeze

  PENDING  = 'pending'
  FINISHED = 'finished'

  attr_reader :bet, :cards

  def initialize(bet, cards = nil)
    @bet = bet
    @cards = cards || []
    @state = PENDING
  end

  def <<(card)
    @cards << card
  end
  alias :add <<

  # NOTE: To handle aces, we always add by 11
  # Then, we subtract by 10 per ace if above 21
  def sum
    sum_with_soft.first
  end

  def to_s
    @cards.join(', ')
  end

  def first
    @cards.first
  end

  def includes_ace?
    @cards.any? { |card| card.number == 'A' }
  end

  def bust?
    sum > 21
  end

  def blackjack?
    sum == 21 && @cards.count == 2
  end

  def soft17?
    total, soft = sum_with_soft

    soft && total == 17
  end

  def can_free_split?
    can_split? && value(@cards.first.number) != 10
  end

  def can_split?
    (@cards.count == 2) && (@cards.first.number == @cards.last.number)
  end

  def can_free_double?
    can_double? && [9, 10, 11].include?(sum)
  end

  def can_double?
    @cards.count == 2
  end

  # Splitting requires two new cards
  # Returns the new second hand
  def split(card1, card2)
    add(card1)
    self.class.new(@bet, [@cards.shift, card2])
  end

  def double(card)
    @bet *= 2
    add(card)
    finish # Doubling ends your turn
  end

  def hit(card)
    add(card)
    finish if sum >= 21
  end

  def finished?
    @state == FINISHED
  end

  def dealer_stay
    sum > 17 || (sum == 17 && !soft17?)
  end

  private

  def finish
    @state = FINISHED
  end

  def sum_with_soft
    total = 0
    aces = 0
    soft = false # We could also check final aces == original_aces

    @cards.each do |card|
      card_value = value(card.number)

      total += card_value

      if card_value == 11
        aces += 1
        soft = true
      end
    end

    while aces.positive? && total > 21
      soft = false
      aces -= 1
      total -= 10
    end

    [total, soft]
  end

  # NOTE: number can be "A", "2", . . ., "J", "Q", "K"
  def value(number)
    if number == 'A'
      11
    elsif ROYALS.include?(number)
      10
    else
      number.to_i
    end
  end
end
