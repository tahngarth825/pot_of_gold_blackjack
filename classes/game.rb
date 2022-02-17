# frozen_string_literal: true

require_relative 'deck'
require_relative 'hand'

class Game
  STARTING_MONEY = 500
  MINIMUM_BET = 5

  HIT         = 'hit'
  STAY        = 'stay'
  FREE_SPLIT  = 'free_split'
  SPLIT       = 'split'
  FREE_DOUBLE = 'free_double'
  DOUBLE      = 'double'

  BASE_ACTIONS = [STAY, HIT].freeze

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

  def self.play
    new.play
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
    puts "----- STARTING GAME -----"
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
    puts 'Bet your main amount.'
    puts "Min: #{MINIMUM_BET}, Max: #{@money}"

    @original_bet = prompt_bet

    puts "\n"
  end

  def bet_side
    puts 'Bet your side bet.'
    puts "Min: #{MINIMUM_BET}, Max: #{@money}"
    puts 'Enter 0 to skip.'

    @side_bet = prompt_bet(optional: true)

    puts "\n"
  end

  def prompt_bet(optional: false)
    if @money < MINIMUM_BET
      return 0 if optional

      raise "Not enough money left! You have only have $#{@money}."
    end

    bet_amount = nil

    while bet_amount.nil?
      puts 'Input bet:'
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
    puts "\n"
    puts "----- User's turn -----"
    until @player_hands.all?(&:finished?)
      @player_hands.each do |hand|
        puts "Your hand: #{hand}"
        puts "Sum: #{hand.sum}"

        until hand.finished?
          display_dealer
          possible_actions = determine_actions(hand)

          puts "You can: #{possible_actions}"

          action = gets.chomp
          until possible_actions.include?(action)
            puts 'You did not pick a valid option'
            puts "You can: #{possible_actions}"
            action = gets.chomp
          end

          resolve_action(action, hand)

          puts "\n"
          puts "Your hand is now: #{hand}"
          puts "Your hand has a sum of #{hand.sum}"
          sleep 1
        end
      end
    end

    puts "\n"
    puts "----- Dealer's turn. ------"
    puts "Dealer's hand is: #{@dealer_hand}"
    puts "Dealer's sum is: #{@dealer_hand.sum}"
    until @dealer_hand.dealer_stay
      @dealer_hand.hit(@deck.draw)
      puts "Dealer has sum of #{@dealer_hand.sum}"
      sleep 2
    end
  end

  # NOTE: User should not know dealer's sum
  def display_dealer
    puts "Dealer card showing: #{@dealer_hand.first}"
    puts "\n"
  end

  def display_cards
    puts "\n"
    puts "--------------------------------------------"
    puts "Your hands: #{@player_hands.map(&:to_s)}"
    puts "Sum: #{@player_hands.map(&:sum)}"

    display_dealer
  end

  def resolve_hand(hand)
    puts "\n"
    puts "For hand: #{hand}"

    if hand.blackjack?
      gains = 1.5 * hand.bet
      @money += gains

      puts "BLACKJACK! You won: $#{gains}!"
    elsif hand.bust?
      puts "BUST!"
    elsif @dealer_hand.sum == 22
      puts "PUSH! Dealer has 22!"
    elsif @dealer_hand.bust?
      @money += hand.bet
      puts "Dealer busts! You won: $#{hand.bet}"
    elsif hand.sum > @dealer_hand.sum
      @money += hand.bet

      puts "Your sum of #{hand.sum} beats dealer's sum of : #{@dealer_hand.sum}"
      puts "You win: $#{hand.bet}"
    elsif @dealer_hand.sum > hand.sum
      puts "Your sum of #{hand.sum} loses to dealer's sum of : #{@dealer_hand.sum}"
      puts "Dealer beat you :("
    else
      puts "Push! Same value hands"
    end
  end

  def determine_actions(hand)
    actions = BASE_ACTIONS.dup

    if hand.can_free_split?
      actions << FREE_SPLIT
    elsif hand.can_split? && @money >= @original_bet
      actions << SPLIT
    end

    if hand.can_free_double?
      actions << FREE_DOUBLE
    elsif hand.can_double? && @money >= @original_bet
      actions << DOUBLE
    end

    actions
  end

  def resolve_action(action, hand)
    case action
    when HIT
      hand.hit(@deck.draw)
    when STAY
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

  def resolve_game
    @player_hands.each do |hand|
      resolve_hand(hand)
    end

    if @side_bet.positive?
      if @gold_coins.positive?
        gains = @side_bet * POT_OF_GOLD_BONUS[@gold_coins]
        puts "\n"
        puts "Your side bet won!"
        puts "You had #{@gold_coins} gold coins!"
        puts "That nets you: $#{gains}"
        @money += gains
      else
        puts "\n"
        puts "You lost your side bet :("
      end
    end
  end

  def prompt_play_again
    puts "\n"
    puts "----- GAME OVER -----"
    puts "\n"
    play if @money > MINIMUM_BET

    raise "You're out of money!"
  end
end
