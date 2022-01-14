class Hand
  ROYALS = %w[J Q K].to_set.freeze

  def initialize(cards = nil)
    @cards = cards || []
  end

  def <<(card)
    @cards << card
  end
  alias :add <<

  # NOTE: To handle aces, we always add by 11
  # Then, we subtract by 10 per ace if above 21
  def sum
    total = 0
    aces = 0

    @cards.each do |card|
      card_value = value(card.number)
      total += card_value
      aces += 1 if card_value == 11
    end

    while aces.positive? && total > 21
      aces -= 1
      total -= 10
    end

    total
  end

  def to_s
    @cards.join(', ')
  end

  private

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
