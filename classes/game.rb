# frozen_string_literal: true

require_relative 'deck'
require_relative 'hand'

class Game
  STARTING_MONEY = 500
  MINIMUM_BET = 5

  FINISH_STATES = %w[won lost push blackjack].to_set.freeze

  BASE_ACTIONS = [PASS, HIT].freeze

  HIT         = 'hit'
  PASS        = 'pass'
  FREE_SPLIT  = 'free_split'
  SPLIT       = 'split'
  FREE_DOUBLE = 'free_double'
  DOUBLE      = 'double'

  POT_OF_GOLD_BONUS = {
    0 => 0,
    1 => 3,
    2 => 10,
    3 => 30,
    4 => 60,
    5 => 100,
    6 => 300,
    7 => 1000
  }.freeze

  def self.start
    new.start
  end

  def initialize
    @money = STARTING_MONEY
  end

  def play
    start
    play_round
    resolve_game
    prompt_play_again
  end

  private

  def start
    reset_state

    bet_money
    bet_side

    initialize_hands
  end

  def reset_state
    @deck = Deck.new
    @actions_available = []
    @gold_coins = 0
    @original_bet = 0
    @side_bet = 0
  end

  def bet_money
    puts "Bet your main amount. Min: #{MINIMUM_BET}, Max: #{@money}"

    @original_bet = prompt_bet
  end

  def bet_side
    puts 'Bet your side bet. Enter 0 to skip.'

    @side_bet = prompt_bet(optional: true)
  end

  def prompt_bet(optional: false)
    if @money < MINIMUM_BET
      return 0 if optional

      raise "Not enough money left! You have only have $#{@money}."
    end

    bet_amount = nil

    while bet_amount.nil?
      bet_amount = gets.chomp.to_i

      break if bet_amount.between?(MINIMUM_BET, @money)

      return 0 if optional && bet_amount < MINIMUM_BET

      puts "Your bet of $#{bet_amount} must be between $#{MINIMUM_BET} and $#{@money}"
      bet_amount = nil
    end

    @money -= bet_amount
    puts "You bet $#{bet_amount}, and you have $#{@money} left."

    bet_amount
  end

  def initialize_hands
    @dealer_hand = Hand.new(@original_bet)
    @player_hands = [Hand.new(@original_bet)]

    2.times do
      @player_hands.first << @deck.draw
      @dealer_hand << @deck.draw
    end
  end

  def play_round
    # User's turn
    until @player_hands.all?(&:finished?)
      display_cards

      @player_hands.each do |hand|
        until hand.finished?
          puts "Current hand: #{hand}"

          possible_actions = determine_actions(hand)

          puts "You can do one of the following: #{possible_actions}"

          action = gets.chomp
          until possible_actions.include?(action)
            puts 'You did not pick a valid option'
            puts "You can do one of the following: #{possible_actions}"
            action = gets.chomp
          end

          resolve_action(action, hand)
        end
      end
    end

    # Dealer's turn
    @dealer_hand.hit(@deck.draw) until @dealer_hand.dealer_stay
  end

  def display_cards
    puts "Your hands: #{@player_hands}"
    puts "Dealer card showing: #{@dealer_hand.first}"
  end

  def resolve_hand(hand)
    if hand.blackjack?
      @money += 1.5 * hand.bet
    elsif hand.bust?
      # Do nothing
    elsif dealer_sum == 22
      # Do nothing
    elsif @dealer_hand.bust?
      @money += hand.bet
    elsif player_sum > dealer_sum
      @money += hand.bet
    elsif dealer_sum > player_sum
      # Do nothing
    else # Push
      # Do nothing
    end
  end

  def determine_actions(hand)
    actions = BASE_ACTIONS.dup

    if hand.can_free_split?
      actions << FREE_SPLIT
    elsif hand.can_split? && @money >= original_bet
      actions << SPLIT
    end

    if hand.can_free_double?
      actions << FREE_DOUBLE
    elsif hand.can_double? && @money >= original_bet
      actions << DOUBLE
    end

    actions
  end

  def resolve_action(action, hand)
    case action
    when HIT
      hand.hit(@deck.draw)
    when PASS
      hand.finish
    when FREE_SPLIT
      @player_hands << hand.split(@deck.draw, @deck.draw)
      @gold_coins += 1 if @side_bet.positive?
    when SPLIT
      @player_hands << hand.split(@deck.draw, @deck.draw)
      @money -= @original_bet
    when FREE_DOUBLE
      hand.double(@deck.draw)
      @gold_coins += 1 if @side_bet.positive?
    when DOUBLE
      hand.double(@deck.draw)
      @money -= @original_bet
    end
  end

  def player_sum
    @player_hands.sum
  end

  def dealer_sum
    @dealer_hand.sum
  end

  def resolve_game
    @player_hands.each do |hand|
      resolve_hand(hand)
    end

    if @side_bet.positive? && @gold_coins.positive?
      @money += @side_bet * POT_OF_GOLD_BONUS[@gold_coins]
    end
  end

  def prompt_play_again
    play if @money > MINIMUM_BET

    raise "You're out of money!"
  end
end
