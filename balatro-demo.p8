pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Globals
screen_width = 128
screen_height = 128
card_width = 8
card_height = 8
error_message = ""
hand_type_text = ""
draw_hand_gap = 4 
draw_special_cards_gap = 10
init_draw = true 
max_selected = 5
card_selected_count = 0
suits = {'H', 'D', 'C', 'S'}
sprite_index_lookup_table = {}
suit_colors = {S=5,C=12,H=8,D=9}
ranks = {
	{rank = 'A', base_chips = 11},
	{rank = 'K', base_chips = 10},
	{rank = 'Q', base_chips = 10},
	{rank = 'J', base_chips = 10},
	{rank = '10', base_chips = 10},
	{rank = '9', base_chips = 9},
	{rank = '8', base_chips = 8},
	{rank = '7', base_chips = 7},
	{rank = '6', base_chips = 6},
	{rank = '5', base_chips = 5},
	{rank = '4', base_chips = 4},
	{rank = '3', base_chips = 3},
	{rank = '2', base_chips = 2},
}	
hand_types = {
	["Royal Flush"] = {base_chips = 100, base_mult = 8, level = 1},
	["Straight Flush"] = {base_chips = 100, base_mult = 8, level = 1},
	["Four of a Kind"] = {base_chips = 60, base_mult = 7, level = 1},
	["Full House"] = {base_chips = 40, base_mult = 4, level = 1},
	["Flush"] = {base_chips = 35, base_mult = 4, level = 1},
	["Straight"] = {base_chips = 30, base_mult = 4, level = 1},
	["Three of a Kind"] = {base_chips = 30, base_mult = 3, level = 1},
	["Two Pair"] = {base_chips = 20, base_mult = 2, level = 1},
	["Pair"] = {base_chips = 10, base_mult = 2, level = 1},
	["High Card"] = {base_chips = 5, base_mult = 1, level = 1}
}
hand_types_copy = {}
special_cards = {
	Jokers = {
		{
			name = "Add 4 Mult",
			price = 2,
			effect = function()
				mult = mult + 4
			end,
			sprite_index = 128,
			description = "Adds 4 to your mult",
			type = "Joker"
		},
		{
			name = "Add 8 Mult",
			price = 3,
			effect = function()
				mult = mult + 8
			end,
			sprite_index = 129, 
			description = "Adds 8 to your mult",
			type = "Joker"
		},
		{
			name = "Add 12 Mult",
			price = 4,
			effect = function()
				mult = mult + 12 
			end,
			sprite_index = 130, 
			description = "Adds 12 to your mult",
			type = "Joker"
		},
		{
			name = "Add Random Mult",
			price = 4,
			effect = function()
				mult = mult + flr(rnd(25))
			end,
			sprite_index = 131, 
			description = "Adds a random amount of mult. Lowest being 0, highest being 25",
			type = "Joker"
		},
		{
			name = "Times 1.5 Mult",
			price = 6,
			effect = function()
				mult = mult * 1.5 
			end,
			sprite_index = 132, 
			description = "Multiplies your mult by 1.5",
			type = "Joker"
		},
		{
			name = "Times 2 Mult",
			price = 7,
			effect = function()
				mult = mult * 2 
			end,
			sprite_index = 133, 
			description = "Multiplies your mult by 2",
			type = "Joker"
		},
		{
			name = "Times 3 Mult",
			price = 8,
			effect = function()
				mult = mult * 3 
			end,
			sprite_index = 134, 
			description = "Multiplies your mult by 3",
			type = "Joker"
		},
		{
			name = "Add 30 Chips",
			price = 2,
			effect = function()
				chips = chips + 30
			end,
			sprite_index = 135, 
			description = "Adds 30 to your chips",
			type = "Joker"
		},
		{
			name = "Add 60 Chips",
			price = 3,
			effect = function()
				chips = chips + 60
			end,
			sprite_index = 136, 
			description = "Adds 60 to your chips",
			type = "Joker"
		},
		{
			name = "Add 90 Chips",
			price = 4,
			effect = function()
				chips = chips + 90
			end,
			sprite_index = 137, 
			description = "Adds 90 to your chips",
			type = "Joker"
		},
		{
			name = "Add Random Chips",
			price = 5,
			effect = function()
				local chip_options = {}
				local step = 10 
				local amount = 0
				while (amount <= 150) do
					add(chip_options, amount)
					amount = amount + step
				end
				chips = chips + rnd(chip_options)
			end,
			sprite_index = 138, 
			description = "Adds a random amount of chips. Lowest being 0, highest being 150",
			type = "Joker"
		}
	},
	Planets = {
		{
			name = "Level Up Royal Flush",
			price = 5,
			effect = function()
				level_up_hand_type("Royal Flush", 5, 50)
			end,
			sprite_index = 153,
			description = "Levels up the Royal Flush. + 5 mult and + 50 chips",
			type = "Planet"
		},
		{
			name = "Level Up Straight Flush",
			price = 5,
			effect = function()
				level_up_hand_type("Straight Flush", 4, 40)
			end,
			sprite_index = 152,
			description = "Levels up the Straight Flush. + 4 mult and + 40 chips",
			type = "Planet"
		},
		{
			name = "Level Up Four of a Kind",
			price = 4,
			effect = function()
				level_up_hand_type("Four of a Kind", 3, 30)
			end,
			sprite_index = 151,
			description = "Levels up the Four of a Kind. + 3 mult and + 30 chips",
			type = "Planet"
		},
		{
			name = "Level Up Full House",
			price = 3,
			effect = function()
				level_up_hand_type("Full House", 2, 25)
			end,
			sprite_index = 150,
			description = "Levels up the Full House. + 2 mult and + 25 chips",
			type = "Planet"
		},
		{
			name = "Level Up Flush",
			price = 3,
			effect = function()
				level_up_hand_type("Flush", 2, 15)
			end,
			sprite_index = 149,
			description = "Levels up the Flush. + 2 mult and + 15 chips",
			type = "Planet"
		},
		{
			name = "Level Up Straight",
			price = 3,
			effect = function()
				level_up_hand_type("Straight", 3, 30)
			end,
			sprite_index = 148,
			description = "Levels up the Straight. + 3 mult and + 30 chips",
			type = "Planet"
		},
		{
			name = "Level Up Three of a Kind",
			price = 2,
			effect = function()
				level_up_hand_type("Three of a Kind", 2, 20)
			end,
			sprite_index = 147,
			description = "Levels up the Three of a Kind. + 2 mult and + 20 chips",
			type = "Planet"
		},
		{
			name = "Level Up Two Pair",
			price = 2,
			effect = function()
				level_up_hand_type("Two Pair", 1, 20)
			end,
			sprite_index = 146,
			description = "Levels up the Two Pair. + 1 mult and + 20 chips",
			type = "Planet"
		},
		{
			name = "Level Up Pair",
			price = 1,
			effect = function()
				level_up_hand_type("Pair", 1, 15)
			end,
			sprite_index = 145,
			description = "Levels up the Pair. + 1 mult and + 15 chips",
			type = "Planet"
		},
		{
			name = "Level Up High Card",
			price = 1,
			effect = function()
				level_up_hand_type("High Card", 1, 10)
			end,
			sprite_index = 144,
			description = "Levels up the High Card. + 1 mult and + 10 chips",
			type = "Planet"
		}
	},
	Tarots = {
		{
			name = "Increase Rank",
			price = 2,
			effect = function(tarot)
				if #selected_cards <= 2 then
					for card in all(selected_cards) do
						local higher_rank = find_1_rank_higher(card.rank)
						card.sprite_index = sprite_index_lookup_table[higher_rank]
						card.rank = higher_rank 
						card.order = find_rank_order(higher_rank)
						card.chips = find_rank_base_chips(higher_rank)
						card.selected = false
						card.pos_y = card.pos_y + 10
					end
					card_selected_count = 0
					del(tarot_cards, tarot)
					init_draw = true
					sort_by_rank_decreasing(hand)
				else
					sfx(sfx_error_message)
					error_message = "Can only use this\n tarot card with 2 cards"
				end
			end,
			sprite_index = 160,
			description = "Increases the rank of two selected cards by 1",
			type = "Tarot"
		},
		{
			name = "Change to Hearts",
			price = 2,
			effect = function(tarot)
				change_to_suit("H", tarot)	
			end,
			sprite_index = 161,
			description = "Changes the suit of 3 selected cards to Hearts",
			type = "Tarot"
		},
		{
			name = "Change to Diamonds",
			price = 2,
			effect = function(tarot)
				change_to_suit("D", tarot)	
			end,
			sprite_index = 162,
			description = "Changes the suit of 3 selected cards to Diamonds",
			type = "Tarot"
		},
		{
			name = "Change to Clubs",
			price = 2,
			effect = function(tarot)
				change_to_suit("C", tarot)	
			end,
			sprite_index = 163,
			description = "Changes the suit of 3 selected cards to Clubs",
			type = "Tarot"
		},
		{
			name = "Change to Spades",
			price = 2,
			effect = function(tarot)
				change_to_suit("S", tarot)	
			end,
			sprite_index = 164,
			description = "Changes the suit of 3 selected cards to Spades",
			type = "Tarot"
		},
		{
			name = "Add 4 Mult",
			price = 2,
			effect = function(tarot)
				if #selected_cards <= 2 then
					for card in all(selected_cards) do
						card.mult = 4
						card.selected = false
						card.pos_y = card.pos_y + 10
						if card.effect_chips > 0 then
							card.effect_chips = 0
						end
					end
					card_selected_count = 0
					del(tarot_cards, tarot)
				else
					sfx(sfx_error_message)
					error_message = "Can only use this\n tarot card with 2 cards"
				end
			end,
			sprite_index = 165,
			description = "Gives two cards the ability to add 4 Mult when scored",
			type = "Tarot"
		},
		{
			name = "Add 30 Chips",
			price = 2,
			effect = function(tarot)
				if #selected_cards <= 2 then
					for card in all(selected_cards) do
						card.effect_chips = 30 
						card.selected = false
						card.pos_y = card.pos_y + 10
						if card.mult > 0 then
							card.mult = 0
						end
					end
					card_selected_count = 0
					del(tarot_cards, tarot)
				else
					sfx(sfx_error_message)
					error_message = "Can only use this\n tarot card with 2 cards"
				end
			end,
			sprite_index = 166,
			description = "Gives two cards the ability to add 30 Chips when scored",
			type = "Tarot"
		},
		{
			name = "Multiply Money by 2",
			price = 4,
			effect = function()
				if money >= 20 then
					money = money + 20
				else
					money = money * 2
				end
			end,
			sprite_index = 167,
			description = "Multiplies your money by 2 with the max being 20",
			type = "Tarot"
		},
		{
			name = "Delete Cards",
			price = 2,
			effect = function(tarot)
				if #selected_cards <= 2 then
					for card in all(selected_cards) do
						del(base_deck, card)
						del(hand, card)
					end
					deal_hand(shuffled_deck, #selected_cards)
					card_selected_count = 0
					del(tarot_cards, tarot)
					init_draw = true
					sort_by_rank_decreasing(hand)
					selected_cards = {}
					hand_type_text = ""
				else
					sfx(sfx_error_message)
					error_message = "Can only use this\n tarot card with 2 cards"
				end
			end,
			sprite_index = 168,
			description = "Deletes two selected cards from the deck",
			type = "Tarot"
		},
	}
}

deck_sprite_index = 68
deck_sprite_pos_x = 105
deck_sprite_pos_y = 100

-- buttons
btn_width = 16
btn_height = 16
btn_gap = 10
btn_play_hand_sprite_index = 64
btn_play_hand_pos_x = 32 
btn_play_hand_pos_y = 110
btn_discard_hand_sprite_index = 66
btn_discard_hand_pos_x = 80 
btn_discard_hand_pos_y = 110
btn_buy_sprite_index = 74
btn_use_sprite_index = 75 
btn_sell_sprite_index = 76 

btn_go_next_sprite_index = 70
btn_go_next_pos_x = 20 
btn_go_next_pos_y = 50 
btn_reroll_sprite_index = 72
btn_reroll_pos_x = 20 
btn_reroll_pos_y = 70 

btn_full_deck_pos_x = 12 
btn_full_deck_pos_y = 100 
btn_full_deck_text = "Full Deck"
btn_remaining_deck_pos_x = 62 
btn_remaining_deck_pos_y = 100 
btn_remaining_deck_text = "Remaining Deck"
btn_exit_view_deck_pox_x = 52
btn_exit_view_deck_pox_y = 115 
btn_exit_view_deck_text = "Exit"

-- Sound Effects
sfx_card_select = 0
sfx_discard_btn_clicked = 1
sfx_play_btn_clicked = 2
sfx_win_state = 3
sfx_lose_state = 4
sfx_buy_btn_clicked = 5
sfx_buy_btn_clicked_planet = 6
sfx_sell_btn_clicked = 7
sfx_use_btn_clicked = 8
sfx_load_game = 9
sfx_error_message = 10

-- Game State
hand = {}
selected_cards = {}
shop_options = {}
scored_cards = {}
joker_cards = {}
tarot_cards = {}
spade_cards = {} 
diamond_cards = {} 
heart_cards = {} 
club_cards = {}
joker_limit = 5
tarot_limit = 2
reroll_price = 5
hand_size = 8
score = 0
score_cap = 32767
chips = 0
mult = 0
hands = 4
discards = 4
money = 4
round = 1
goal_score = 300
in_shop = false
is_viewing_deck = false
money_earned_per_round = 3

-- Input
mx = 0
my = 0

-- Gameplay
function _init()
    -- initialize data
    poke(0x5F2D, 0x7)
	poke(0x5f2d, 0x3) -- mouse stuff?
	build_sprite_index_lookup_table()
	make_hand_types_copy()
	add_resettable_params_to_special_cards()
	base_deck = create_base_deck()
	shuffled_deck = shuffle_deck(base_deck)
	deal_hand(shuffled_deck, hand_size)
	sfx(sfx_load_game)
end

function _update()
    --register inputs
    mx = stat(32)
    my = stat(33)

    -- Check mouse buttons
	-- btn(5) left click, btn(4) right click
	if btnp(5) and not in_shop then 
		hand_collision()
		update_selected_cards()
		play_button_clicked()
		discard_button_clicked()
		use_button_clicked()
		sell_button_clicked()
		view_deck_button_clicked()
		full_deck_button_clicked()
		remaining_deck_button_clicked()
		exit_view_deck_button_clicked()
	elseif btnp(5) and in_shop then
		go_next_button_clicked()
		buy_button_clicked()
		reroll_button_clicked()
		sell_button_clicked()
		view_deck_button_clicked()
		full_deck_button_clicked()
		exit_view_deck_button_clicked()
	end

    -- Check keyboard
    --if stat(30) then
    --	end
end

function _draw()
    -- draw stuff
    cls()
	-- conditional draw
	if in_shop and not is_viewing_deck then
		draw_background()
		draw_score()
		draw_shop()
		draw_go_next_and_reroll_button()
		draw_shop_options()
		draw_deck()
		-- always draw
		draw_hands_and_discards()
		draw_money()
		draw_round_and_score()
		draw_joker_cards()
		draw_tarot_cards()
	elseif not in_shop and not is_viewing_deck then
    	draw_background()
    	draw_hand()
		draw_play_discard_buttons()
		draw_chips_and_mult()
		draw_score()
		draw_hand_type(hand_type_text)
		draw_special_card_pixels()
		draw_deck()
		-- always draw
		draw_hands_and_discards()
		draw_money()
		draw_round_and_score()
		draw_joker_cards()
		draw_tarot_cards()
	elseif is_viewing_deck then
		draw_background()
		draw_view_of_deck()
		draw_full_deck_button()
		if not in_shop then
			draw_remaining_deck_button()
		end
		draw_exit_button()
	end
    draw_mouse(mx, my)
	draw_error_message()
end

function score_hand()
	-- Score cards 
	for card in all(scored_cards) do
		chips = chips + card.chips + card.effect_chips
		mult = mult + card.mult
	end
	score_jokers()
	score = score + (chips * mult)
	if score < 0 then
		score = score_cap
	end
	chips = 0
	mult = 0
	hand_type_text = ""
end

function score_jokers()
	for joker in all(joker_cards) do
		joker.effect()
	end
end

function update_selected_cards()
	for card in all(hand) do
		if card.selected == true and not contains(selected_cards, card) then
			add(selected_cards, card)
		elseif card.selected == false and contains(selected_cards, card) then
			del(selected_cards, card)	
		end
	end
	scored_cards = {}
	local hand_type = check_hand_type()
	if hand_type ~= "None" then
		hand_type_text = hand_type
		chips = 0
		mult = 0
		chips = chips + hand_types[hand_type].base_chips
		mult = mult + hand_types[hand_type].base_mult
	end
end

function check_hand_type()
	if is_royal_flush() then
		return "Royal Flush"	
	elseif is_straight_flush() then
		return "Straight Flush"
	elseif is_four_of_a_kind() then
		return "Four of a Kind"
	elseif is_full_house() then
		return "Full House"
	elseif is_flush() then
		return "Flush"
	elseif is_straight() then
		return "Straight"
	elseif is_three_of_a_kind() then
		return "Three of a Kind"
	elseif is_two_pair() then
		return "Two Pair"
	elseif is_pair() then
		return "Pair"	
	elseif is_high_card() then
		return "High Card"
	else
		hand_type_text = ""
		return "None"
	end
end

function update_round_and_score() 
	round = round + 1
	goal_score = flr(goal_score * 1.5)
	if goal_score < 0 then
		goal_score = score_cap
	end
end

function win_state()
	sfx(sfx_win_state)
	error_message = ""
	update_round_and_score()	
	cash_out_interest()
	cash_out_money_earned_per_round()
	cash_out_money_earned_per_hand_remaining()
	add_cards_to_shop()
	card_selected_count = 0
	scored_cards = {}
	hands = 4
	discards = 4
	shuffled_deck = shuffle_deck(base_deck)
	reset_card_params()
	selected_cards = {}
	scored_cards = {}
	hand = {}
	init_draw = true
	deal_hand(shuffled_deck, hand_size)
end

function lose_state()
	sfx(sfx_lose_state)
	base_deck = create_base_deck()
	tarot_cards = {}
	joker_cards = {}
	round = 1
	goal_score = 300
	card_selected_count = 0
	scored_cards = {}
	hands = 4
	discards = 4
	score = 0
	reroll_price = 5
	shuffled_deck = shuffle_deck(base_deck)
	reset_card_params()
	selected_cards = {}
	scored_cards = {}
	shop_options = {}
	hand = {}
	hand_types = hand_types_copy -- TODO not working
	init_draw = true
	deal_hand(shuffled_deck, hand_size)
	money = 4
end

function level_up_hand_type(hand_type_name, mult_amount, chip_amount)
	local ht = hand_types[hand_type_name]
	ht.base_mult = ht.base_mult + mult_amount 
	ht.base_chips = ht.base_chips + chip_amount 
	ht.level = ht.level + 1 
end

-- Money
function cash_out_interest()
	if money >= 25 then
		money = money + 5
	elseif money >= 5 then
		local interest = flr(money / 5)		
		money = money + interest
	end
end

function cash_out_money_earned_per_round()
	if money_earned_per_round == 3 then
		money = money + money_earned_per_round
		money_earned_per_round = 4
	elseif money_earned_per_round == 4 then
		money = money + money_earned_per_round
		money_earned_per_round = 5
	else	
		money = money + money_earned_per_round
		money_earned_per_round = 3
	end
end

function cash_out_money_earned_per_hand_remaining()
	money = money + hands
end

-- Deck
function create_base_deck()
	local base_deck = {}

	-- Set the sorting order		
	for i, card in pairs(ranks) do
    	card.order = 14 - i
	end

	-- Create deck
	for x=1,#ranks do
		for y=1,#suits do
			card_info = {
				rank = ranks[x].rank,
				suit = suits[y],
				chips = ranks[x].base_chips,
				effect_chips = 0,
				mult = 0,
				sprite_index = sprite_index_lookup_table[ranks[x]["rank"]],
				order = ranks[x].order,
				-- Resettable params
				selected = false,
				pos_x = 0,
				pos_y = 0
			}
			add(base_deck, card_info)
		end
	end
	return base_deck
end

function shuffle_deck(deck)
	copy_deck = {}
	for x=1,#deck do
		add(copy_deck, deck[x])
	end
	shuffled_deck = {}

	for x=1,#copy_deck do
		random_card = rnd(copy_deck)
		add(shuffled_deck, random_card)
		del(copy_deck, random_card)
	end
	return shuffled_deck
end

function deal_hand(shuffled_deck, cards_to_deal)
	if #shuffled_deck < cards_to_deal then
		for card in all(shuffled_deck) do
			add(hand, card)				
			del(shuffled_deck, card)
		end
	else
		for x=1,cards_to_deal do
			add(hand, shuffled_deck[1])				
			del(shuffled_deck, shuffled_deck[1])
		end
	end
	sort_by_rank_decreasing(hand)
end

function reset_card_params()
	for card in all(shuffled_deck) do
		if card.pos_x != 0 or card.pos_y != 0 or card.selected != false then
			card.pos_x = 0
			card.pos_y = 0
			card.selected = false
		end
	end
end

function build_sprite_index_lookup_table()
	-- Create deck
	for x=1,#ranks do
		sprite_index_lookup_table[ranks[x]["rank"]] = x-1
	end
end

function add_resettable_params_to_special_cards()
	for joker in all(special_cards["Jokers"]) do
		joker.selected = false
		joker.pos_x = 0 
		joker.pos_y = 0 
	end
	for planet in all(special_cards["Planets"]) do
		planet.selected = false
		planet.pos_x = 0 
		planet.pos_y = 0 
	end
	for tarot in all(special_cards["Tarots"]) do
		tarot.selected = false
		tarot.pos_x = 0
		tarot.pos_y = 0
	end
end

function make_hand_types_copy()
	for k, v in pairs(hand_types) do
	    local new_table = {}
	    for sub_k, sub_v in pairs(v) do
	        new_table[sub_k] = sub_v
	    end
	    hand_types_copy[k] = new_table
	end    
end

function add_cards_to_shop()
	random_joker = find_random_unique_shop_option("Jokers", joker_cards) -- don't repeat cards
	add(shop_options, random_joker) 

	random_planet = rnd(special_cards["Planets"])
	add(shop_options, random_planet)

	random_tarot = find_random_unique_shop_option("Tarots", tarot_cards) -- don't repeat cards
	add(shop_options, random_tarot)

	-- TODO TEST If you want to test specific cards, use below 
	--add(shop_options, get_special_card_by_name("Change to Diamonds", "Tarots"))
end

function create_view_of_deck(table)
	heart_cards = {}
	diamond_cards = {}
	club_cards = {}
	spade_cards = {}

	for card in all(table) do
		if card.suit == "H" then
			add(heart_cards, card)
		elseif card.suit == "D" then
			add(diamond_cards, card)
		elseif card.suit == "C" then
			add(club_cards, card)
		elseif card.suit == "S" then
			add(spade_cards, card)
		end
	end
	sort_by_rank_decreasing(heart_cards)		
	sort_by_rank_decreasing(diamond_cards)		
	sort_by_rank_decreasing(club_cards)		
	sort_by_rank_decreasing(spade_cards)		
end

-- Graphics 
function draw_background()
    rectfill(0, 0, 128, 128, 3) 
end

function draw_card(card, x, y)
    pal(8,suit_colors[card.suit])
    spr(card.sprite_index, x, y)
    -- print(card.sprite_index,x,y+8)
    pal()
end

function draw_hand()	
	draw_hand_start_x = 15	
	draw_hand_start_y = 90 
	if init_draw then
		for x=1,#hand do
			draw_card(hand[x], draw_hand_start_x, draw_hand_start_y)
			hand[x].pos_x = draw_hand_start_x
			hand[x].pos_y = draw_hand_start_y
			draw_hand_start_x += card_width + draw_hand_gap
		end
		init_draw = false
	else
		for x=1,#hand do
 	   		draw_card(hand[x], hand[x].pos_x, hand[x].pos_y) 
		end
	end
end

function draw_mouse(x, y)
	spr(192, x, y)
end

function select_hand(card)
	if card.selected == false and card_selected_count < max_selected then 
		card.selected = true
		card_selected_count = card_selected_count + 1
		card.pos_y = card.pos_y - 10
	elseif card.selected == true then	
		card.selected = false
		card_selected_count = card_selected_count - 1
		card.pos_y = card.pos_y + 10
		if card_selected_count == 4 then error_message = "" end
	else
		sfx(sfx_error_message)
		error_message = "You can only select 5 \ncards at a time"
	end
end

function draw_play_discard_buttons()
	spr(btn_play_hand_sprite_index, btn_play_hand_pos_x, btn_play_hand_pos_y, 2, 2)
	spr(btn_discard_hand_sprite_index, btn_discard_hand_pos_x, btn_discard_hand_pos_y, 2, 2)
end

function draw_chips_and_mult()
	print(chips .. " X " .. mult, 2, 70, 7)
end

function draw_score()
	if in_shop == false then
		print("Score:" .. score, 2, 60, 7)
	else
		print("Scored Last:" .. score, 30, 120, 7)
	end
end

function draw_hand_type()
	print(hand_type_text, 45, 70, 7)	
end

function draw_deck()
	spr(deck_sprite_index, deck_sprite_pos_x, deck_sprite_pos_y, 2, 2)	
	print(#shuffled_deck .. "/" .. #base_deck, deck_sprite_pos_x, deck_sprite_pos_y + 20, 7)
end

function draw_hands_and_discards()
	print("H:" .. hands, 2, 100, 7)
	print("D:" .. discards, 2, 110, 7)
end

function draw_money()
	print("M:$" .. money, 2, 120, 7)
end

function draw_round_and_score()
	if in_shop == false then
		print("Round:" .. round, 2, 40, 7)
		print("Goal Score:" .. goal_score, 2, 50, 7)
	else
		print("Round:" .. round, 30, 100, 7)
		print("Next Score:" .. goal_score, 30, 110, 7)
	end
end

function draw_shop()
	rectfill(10, 35, 118, 90, 5) -- draw black background
end

function draw_go_next_and_reroll_button()
	spr(btn_go_next_sprite_index, btn_go_next_pos_x, btn_go_next_pos_y, 2, 2)
	spr(btn_reroll_sprite_index, btn_reroll_pos_x, btn_reroll_pos_y, 2, 2)
	print("$"..reroll_price, btn_reroll_pos_x + flr(card_width / 2), btn_reroll_pos_y + btn_height, 7)
end

function draw_shop_options()
	draw_special_hand_start_x = 60	
	draw_special_hand_start_y = 60 

	for special_card in all(shop_options) do
   		spr(special_card.sprite_index, draw_special_hand_start_x, draw_special_hand_start_y)
		spr(btn_buy_sprite_index, draw_special_hand_start_x, draw_special_hand_start_y + card_height)
		print("$" .. special_card.price, draw_special_hand_start_x, draw_special_hand_start_y - card_height, 7)
		special_card.pos_x = draw_special_hand_start_x
		special_card.pos_y = draw_special_hand_start_y
		draw_special_hand_start_x = draw_special_hand_start_x + card_width + draw_special_cards_gap
	end
end

function draw_joker_cards()
	draw_joker_start_x = 15	
	draw_joker_start_y = 4 
	for joker in all(joker_cards) do
   		spr(joker.sprite_index, draw_joker_start_x, draw_joker_start_y)
		spr(btn_sell_sprite_index, draw_joker_start_x - card_width, draw_joker_start_y)
		print("$"..calculate_sell_price(joker.price), draw_joker_start_x - card_width, draw_joker_start_y + card_height + 1, 7)
		joker.pos_x = draw_joker_start_x 
		joker.pos_y = draw_joker_start_y 
		draw_joker_start_x = draw_joker_start_x + card_width + draw_hand_gap + 5
	end
	print(#joker_cards.. "/" .. joker_limit, draw_joker_start_x, draw_joker_start_y, 7)
end

function draw_tarot_cards()
	draw_tarot_start_x = 82	
	draw_tarot_start_y = 20
	for tarot in all(tarot_cards) do
   		spr(tarot.sprite_index, draw_tarot_start_x, draw_tarot_start_y)
		spr(btn_use_sprite_index, draw_tarot_start_x, draw_tarot_start_y + card_height)
		spr(btn_sell_sprite_index, draw_tarot_start_x - card_width, draw_tarot_start_y)
		print("$"..calculate_sell_price(tarot.price), draw_tarot_start_x - card_width, draw_tarot_start_y + card_height + 1, 7)
		tarot.pos_x = draw_tarot_start_x
		tarot.pos_y = draw_tarot_start_y
		draw_tarot_start_x = draw_tarot_start_x + card_width + draw_hand_gap + 5 
	end
	print(#tarot_cards.. "/" .. tarot_limit, draw_tarot_start_x, draw_tarot_start_y, 7)
end

function draw_error_message()
	print(error_message, 30, 35, 8)
end

function draw_special_card_pixels()
	for card in all(hand) do
		if card.effect_chips == 30 then
			pset(card.pos_x + card_width - 1, card.pos_y, 12)
		elseif card.mult == 4 then
			pset(card.pos_x + card_width - 1, card.pos_y, 8)
		end
	end
end

function draw_each_card_in_table(table, start_x, start_y, gap)
	local original_start_x = start_x
	for card in all(table) do
		if start_x > screen_width - card_width then
			start_y = start_y + card_height				
			start_x	= original_start_x
			draw_card(card, start_x, start_y)
			card.pos_x = start_x 
			card.pos_y = start_y 
			start_x = start_x + card_width + gap 
		else
			draw_card(card, start_x, start_y)
			card.pos_x = start_x 
			card.pos_y = start_y 
			start_x = start_x + card_width + gap 
		end
		
		if card.effect_chips == 30 then
			pset(card.pos_x + card_width - 1, card.pos_y, 12)
		elseif card.mult == 4 then
			pset(card.pos_x + card_width - 1, card.pos_y, 8)
		end
	end
end

function draw_view_of_deck()
	view_deck_card_gap_x = 1
	view_deck_card_gap_y = 20
	draw_start_pos_x = 5 
	draw_start_pos_y = 10
	draw_each_card_in_table(heart_cards, draw_start_pos_x, draw_start_pos_y, view_deck_card_gap_x)

	draw_start_pos_y = draw_start_pos_y + view_deck_card_gap_y 
	draw_each_card_in_table(club_cards, draw_start_pos_x, draw_start_pos_y, view_deck_card_gap_x)

	draw_start_pos_y = draw_start_pos_y + view_deck_card_gap_y 
	draw_each_card_in_table(diamond_cards, draw_start_pos_x, draw_start_pos_y, view_deck_card_gap_x)

	draw_start_pos_y = draw_start_pos_y + view_deck_card_gap_y 
	draw_each_card_in_table(spade_cards, draw_start_pos_x, draw_start_pos_y, view_deck_card_gap_x)
end

function draw_button_with_text(x, y, text, color)
    local text_width = #text * 4
    local text_height = 7

    rectfill(x-2, y-2, x + text_width + 2, y + text_height + 2, color)

    print(text, x, y, 7)
end

function draw_full_deck_button()
	draw_button_with_text(btn_full_deck_pos_x, btn_full_deck_pos_y, btn_full_deck_text, 12)
end

function draw_remaining_deck_button()
	draw_button_with_text(btn_remaining_deck_pos_x, btn_remaining_deck_pos_y, btn_remaining_deck_text, 12)
end

function draw_exit_button()
	draw_button_with_text(btn_exit_view_deck_pox_x, btn_exit_view_deck_pox_y, btn_exit_view_deck_text, 8)
end

-- Inputs
function hand_collision()
	-- Check if the mouse is colliding with a card in our hand 
	for x=1, #hand do
		if mx >= hand[x].pos_x and mx < hand[x].pos_x + card_width and
			my >= hand[x].pos_y and my < hand[x].pos_y + card_height then
				sfx(sfx_card_select) --TODO test
				select_hand(hand[x])
				break
		end
	end
end

function mouse_sprite_collision(sx, sy, sw, sh)
    return mx >= sx and mx < sx + sw and
           my >= sy and my < sy + sh
end

function play_button_clicked()
	if mouse_sprite_collision(btn_play_hand_pos_x, btn_play_hand_pos_y, btn_width, btn_height) and #selected_cards > 0 and hands > 0 then
		sfx(sfx_play_btn_clicked)
		hands = hands - 1
		score_hand()
		if score >= goal_score then
			win_state()
			in_shop = true
		else
			for card in all(selected_cards) do
				del(hand, card)	
				del(selected_cards, card)
			end
			deal_hand(shuffled_deck, card_selected_count)
			init_draw = true
			card_selected_count = 0
			scored_cards = {}
			error_message = ""
			if hands == 0 then
				lose_state()
			end
		end
	end
end

function discard_button_clicked()
	if mouse_sprite_collision(btn_discard_hand_pos_x, btn_discard_hand_pos_y, btn_width, btn_height) and #selected_cards > 0 and discards > 0 then
		sfx(sfx_discard_btn_clicked)
		for card in all(selected_cards) do
			del(hand, card)	
			del(selected_cards, card)
		end
		deal_hand(shuffled_deck, card_selected_count)
		init_draw = true
		card_selected_count = 0
		discards = discards - 1
		error_message = ""
	end
end

function go_next_button_clicked()
	if mouse_sprite_collision(btn_go_next_pos_x, btn_go_next_pos_y, btn_width, btn_height)	and in_shop == true then
		sfx(sfx_card_select)
		in_shop = false			
		shop_options = {}
		error_message = ""
		reroll_price = 5
		score = 0
	end
end

function reroll_button_clicked()
	if mouse_sprite_collision(btn_reroll_pos_x, btn_reroll_pos_y, btn_width, btn_height) and in_shop == true and money >= reroll_price then
		sfx(sfx_buy_btn_clicked)
		money = money - reroll_price
		shop_options = {}
		add_cards_to_shop()
		reroll_price = reroll_price + 1
	elseif mouse_sprite_collision(btn_reroll_pos_x, btn_reroll_pos_y, btn_width, btn_height) and in_shop == true and money < reroll_price then
		sfx(sfx_error_message)
		error_message = "You don't have enough\n money to reroll.\n Get your money up."
	end
end

function buy_button_clicked()
	for special_card in all(shop_options) do
		if mouse_sprite_collision(special_card.pos_x, special_card.pos_y + card_height, card_width, card_height) and in_shop == true and money >= special_card.price then
			-- Joker
			if special_card.type == "Joker" and #joker_cards < joker_limit then
				money = money - special_card.price
				sfx(sfx_buy_btn_clicked)
				add(joker_cards, special_card)
				del(shop_options, special_card)
			elseif special_card.type == "Joker" and #joker_cards == joker_limit then 
				sfx(sfx_error_message)
				error_message = "You have reached \nthe max amount \nof jokers"
			end

			-- Tarot 
			if special_card.type == "Tarot" and #tarot_cards < tarot_limit then
				money = money - special_card.price
				sfx(sfx_buy_btn_clicked)
				if special_card.name == "Multiply Money by 2" then
					special_card.effect()	
					del(shop_options, special_card)
				else
					add(tarot_cards, special_card)
					del(shop_options, special_card)
				end
			elseif special_card.type == "Tarot" and #tarot_cards == tarot_limit then
				sfx(sfx_error_message)
				error_message = "You have reached \nthe max amount \nof tarots"
			end

			-- Planet 
			if special_card.type == "Planet" then	
				money = money - special_card.price
				sfx(sfx_buy_btn_clicked_planet)
				special_card.effect()
				del(shop_options, special_card)
			end
		elseif mouse_sprite_collision(special_card.pos_x, special_card.pos_y + card_height, card_width, card_height) and in_shop == true and money < special_card.price then
			sfx(sfx_error_message)
			error_message = "You don't have enough\n money to buy this.\n Get your money up."
		end
	end
end

function use_button_clicked()
	for tarot in all(tarot_cards) do
		if mouse_sprite_collision(tarot.pos_x, tarot.pos_y + card_height, card_width, card_height) and #selected_cards > 0 then
			sfx(sfx_use_btn_clicked)
			tarot.effect(tarot)
		elseif mouse_sprite_collision(tarot.pos_x, tarot.pos_y + card_height, card_width, card_height) and #selected_cards == 0 then
			sfx(sfx_error_message)
			error_message = "Cards must be selected\n to use this tarot card"
		end
	end
end

function sell_button_clicked()
	for tarot in all(tarot_cards) do
		if mouse_sprite_collision(tarot.pos_x - card_width, tarot.pos_y, card_width, card_height) then
			sfx(sfx_sell_btn_clicked)
			money = money + calculate_sell_price(tarot.price)
			del(tarot_cards, tarot)
		end
	end

	for joker in all(joker_cards) do
		if mouse_sprite_collision(joker.pos_x - card_width, joker.pos_y, card_width, card_height) then
			sfx(sfx_sell_btn_clicked)
			money = money + calculate_sell_price(joker.price)
			del(joker_cards, joker)
		end
	end
end

function view_deck_button_clicked()
	if mouse_sprite_collision(deck_sprite_pos_x, deck_sprite_pos_y, btn_width, btn_height) then
		create_view_of_deck(base_deck)
		is_viewing_deck = true

		-- Reset stuff
		card_selected_count = 0
		selected_cards = {}
		for card in all(hand) do
			card.selected = false
		end
		init_draw = true
		hand_type_text = ""
		error_message = ""
		sort_by_rank_decreasing(hand)
	end
end

function full_deck_button_clicked()
	width_and_height = get_button_width_and_height(btn_full_deck_pos_x, btn_full_deck_pos_y, btn_full_deck_text)
	if mouse_sprite_collision(btn_full_deck_pos_x, btn_full_deck_pos_y, width_and_height[1], width_and_height[2]) then	
		sfx(sfx_card_select)
		create_view_of_deck(base_deck)
	end
end

function remaining_deck_button_clicked()
	local width_and_height = get_button_width_and_height(btn_remaining_deck_pos_x, btn_remaining_deck_pos_y, btn_remaining_deck_text)
	if mouse_sprite_collision(btn_remaining_deck_pos_x, btn_remaining_deck_pos_y, width_and_height[1], width_and_height[2]) then	
		sfx(sfx_card_select)
		create_view_of_deck(shuffled_deck)
	end
end

function exit_view_deck_button_clicked()
	local width_and_height = get_button_width_and_height(btn_exit_view_deck_pox_x, btn_exit_view_deck_pox_y, btn_exit_view_deck_text)
	if mouse_sprite_collision(btn_exit_view_deck_pox_x, btn_exit_view_deck_pox_y, width_and_height[1], width_and_height[2]) then	
		sfx(sfx_card_select)
		is_viewing_deck = false 
	end
end

-- Hand Detection
function is_royal_flush()
	if contains_royal(selected_cards) and contains_flush(selected_cards) then
		add_all_cards_to_score(selected_cards)
		return true
	end
	return false
end

function is_straight_flush()
	if contains_flush(selected_cards) and contains_straight(selected_cards) then	
		add_all_cards_to_score(selected_cards)
		return true
	end
	return false
end

function is_four_of_a_kind()
	if contains_four_of_a_kind(selected_cards) then
		sort_by_rank_decreasing(selected_cards)
		for x=1, #selected_cards - 3 do
			if selected_cards[x].rank == selected_cards[x + 1].rank and selected_cards[x].rank == selected_cards[x + 2].rank and selected_cards[x].rank == selected_cards[x + 3].rank then
				add(scored_cards, selected_cards[x])	
				add(scored_cards, selected_cards[x + 1])	
				add(scored_cards, selected_cards[x + 2])	
				add(scored_cards, selected_cards[x + 3])	
				return true
			end
		end
	end
	return false
end

function is_full_house()
	if contains_pair(selected_cards) and contains_three_of_a_kind(selected_cards) then
		add_all_cards_to_score(selected_cards)
		return true
	end
	return false
end

function is_flush()
	if contains_flush(selected_cards) then	
		add_all_cards_to_score(selected_cards)
		return true
	end
	return false
end

function is_straight()
	if contains_straight(selected_cards) then	
		add_all_cards_to_score(selected_cards)
		return true
	end
	return false
end

function is_three_of_a_kind()
	if contains_three_of_a_kind(selected_cards) then
		sort_by_rank_decreasing(selected_cards)
		for x=1, #selected_cards - 2 do
			if selected_cards[x].rank == selected_cards[x + 1].rank and selected_cards[x].rank == selected_cards[x + 2].rank then
				add(scored_cards, selected_cards[x])	
				add(scored_cards, selected_cards[x + 1])	
				add(scored_cards, selected_cards[x + 2])	
				return true
			end
		end
	end
	return false
end

function is_two_pair()
	if contains_two_pair(selected_cards) then
		sort_by_rank_decreasing(selected_cards)
		local times = 0
		for x=1, #selected_cards - 1 do
			if selected_cards[x].rank == selected_cards[x + 1].rank then
				add(scored_cards, selected_cards[x])	
				add(scored_cards, selected_cards[x + 1])	
				times = times + 1
				if times == 2 then
					return true
				end
				x = x + 2
			end
		end
	end
	return false
end

function is_pair()
	if contains_pair(selected_cards) then
		sort_by_rank_decreasing(selected_cards)
		for x=1, #selected_cards - 1 do
			if selected_cards[x].rank == selected_cards[x + 1].rank then
				add(scored_cards, selected_cards[x])	
				add(scored_cards, selected_cards[x + 1])	
				return true
			end
		end
	end
	return false
end

function is_high_card()
	if #selected_cards > 0 then
		sort_by_rank_decreasing(selected_cards)
		add(scored_cards, selected_cards[1])
		return true
	end
	return false
end

-- Helpers
function contains(table, value)
	-- is there a value in a table
    for item in all(table) do
        if item == value then
            return true
        end
    end
    return false
end

function contains_royal(cards)
	if #cards == 5 then
		sort_by_rank_decreasing(cards)
		local start_order = 13
		for x=1, #cards do
			if start_order != cards[x].order then
				return false
			end
			start_order = start_order - 1
		end
		return true 
	end
	return false
end

function contains_four_of_a_kind(cards)
	if contains_multiple_of_a_rank(cards, 4) then
		return true
	end
	return false
end

function contains_flush(cards)
	local suit_arr = {}
	for card in all(cards) do 
		add(suit_arr, card.suit)
	end
	for suit in all(suit_arr) do
		if count(suit_arr, suit) == 5 then				
			return true
		end
	end
	return false
end

function contains_straight(cards)
	if #cards == 5 then
		sort_by_rank_decreasing(cards)
		for x=1,#cards - 1 do
			if cards[x].order != cards[x + 1].order + 1 then
				return false	
			end
		end
		return true 
	else
		return false
	end
end

function contains_three_of_a_kind(cards)
	if contains_multiple_of_a_rank(cards, 3) then
		return true
	end
	return false
end

function contains_two_pair(cards)
	if #cards >= 4 then
		local order_arr = {}
		for card in all(cards) do
			add(order_arr, card.order)		
		end
		local times = 0
		local first_pair = 0
		for order_num in all(order_arr) do 
			if count(order_arr, order_num) == 2 and order_num != first_pair then
				times = times + 1
				first_pair = order_num
				if times == 2 then
					return true
				end
			end
		end
	end
	return false
end

function contains_pair(cards)
	if contains_multiple_of_a_rank(cards, 2) then
		return true
	end
	return false
end

function contains_multiple_of_a_rank(cards, num)
	if #cards >= num then
		local order_arr = {}
		for card in all(cards) do
			add(order_arr, card.order)		
		end
		for order_num in all(order_arr) do 
			if count(order_arr, order_num) == num then
				return true
			end
		end
	end
	return false
end

function add_all_cards_to_score(cards)
	sort_by_rank_decreasing(cards)
	for card in all(cards) do
		add(scored_cards, card)
	end
end

function sort_by_rank_decreasing(cards)
	-- insertion sort
	for i=2,#cards do
		current_order = cards[i].order
		current = cards[i]
		j = i - 1
		while (j >= 1 and current_order > cards[j].order) do
			cards[j + 1] = cards[j]
			j = j - 1
		end
		cards[j + 1] = current
	end
end

function find_1_rank_higher(rank)
	if rank == 'A' then
		return '2'
	end
	for x=1,#ranks do	
		if ranks[x].rank == rank then
			return ranks[x-1].rank
		end
	end
end

function find_rank_order(rank)
	for x=1,#ranks do	
		if ranks[x].rank == rank then
			return ranks[x].order
		end
	end
end

function find_rank_base_chips(rank)
	for x=1,#ranks do	
		if ranks[x].rank == rank then
			return ranks[x].base_chips
		end
	end
end

function get_special_card_by_name(name, type)
	for special_card_type, v in pairs(special_cards) do		
		if special_card_type == type then
			for card in all(v) do
				if card.name == name then
					return card
				end
			end
		end
	end
end

function change_to_suit(suit, tarot)
	if #selected_cards <= 3 then
		for card in all(selected_cards) do
			card.sprite_index = sprite_index_lookup_table[card.rank]
			card.suit = suit 
			card.selected = false
			card.pos_y = card.pos_y + 10
		end
		card_selected_count = 0
		del(tarot_cards, tarot)
	else
		sfx(sfx_error_message)
		error_message = "Can only use this\n tarot card with 3 cards"
	end
end

function calculate_sell_price(price)
	return ceil(price * .40)
end

function find_random_unique_shop_option(special_card_type, table_to_check)
	local unique_table = {}
	for card in all(special_cards[special_card_type]) do
		if not contains(table_to_check, card) then	
			add(unique_table, card)
		end
	end
	return rnd(unique_table)
end

function get_button_width_and_height(x, y, text)
	-- gets the button width from draw_button_with_text
	local text_width = #text * 4
    local text_height = 7
    --rectfill(x-2, y-2, x + text_width + 2, y + text_height + 2, color) -- original math

	local width = 4 + text_width
	local height = 4 + text_height
	return {width, height}
end

-- TEST
function test_print_table(table)
	local text = ""
	for card in all(table) do
		text = text .. " " .. card.rank .. card.suit
	end
	printh(text)
end

__gfx__
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777000000000000000000000000
77788877787778877788887778888887787888877888888778888887788888877778887778888887777788777888888777888887000000000000000000000000
77877877787887777877778777777877787877877877778778777787787777877787777778777777777878777777778778777787000000000000000000000000
78888887788777777877778777777877787877877877778778888887777777877877777778888887778778777777778777777887000000000000000000000000
78777787788887777877878778777877787877877888888778777787777777877888888777777787788888877788888777888777000000000000000000000000
78777787787788777877787778777877787877877777778778777787777777877877778777777787777778777777778778877777000000000000000000000000
78777787787778877788878777888877787888877777778778888887777777877888888778888887777778777888888778888887000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccceeeeeeeeeeeeeeee678c8c8c8c8c8c8c8888888888888888bbbbbbbbbbbbbbbb8aaa8a8a8a8a8888bbbabbba000000000000000000000000
cccccccccccccccce777e777e777eeee67c8c8c8c8c8c8c88887778877777788bb77777bb77777bb888a8a8a888a8aaabaaabaaa000000000000000000000000
c777c7cc777c7c7ce7e7ee7ee7eeeeee678c8c8c8c8c8c8c8878888878888788bb7bbb7bb7bbbbbb8a8a8a8aaaaa8aaabbbabbaa000000000000000000000000
c7c7c7cc7c7c7c7ce7e7ee7ee777eeee67c8c8c8c8c8c8c88788888878888788bb77777bb777bbbb888a888a888a88aaaababaaa000000000000000000000000
c777c7cc777c7c7ce7e7ee7eeee7e77e678c8c8c8c8c8c8c8788778878888788bb7b7bbbb7bbbbbbaaaaaaaa8aaa8aaabbbabbba000000000000000000000000
c7ccc7cc7c7cc7cce7e7ee7eeee7eeee67c8c8c8c8c8c8c88788878878888788bb7bb7bbb7bbbbbbaa8a8aaa888a8aaaaaaaaaaa000000000000000000000000
c7ccc77c7c7cc7cce777e777e777eeee678c8c8c8c8c8c8c8777778877777788bb7bbb7bb77777bbaaa8aaaaaa8a8aaabaaabaaa000000000000000000000000
cccccccccccccccceeeeeeeeeeeeeeee67c8c8c8c8c8c8c88888888888888888bbbbbbbbbbbbbbbbaaa8aaaa888a8888bbbabbba000000000000000000000000
cccccccccccccccceeeeeeeeeeeeeeee678c8c8c8c8c8c8c8888888888888888bbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000
cccccccccccccccceeeeeeeeeeeeeeee67c8c8c8c8c8c8c88777877878787778b7777b777b7bb7bb000000000000000000000000000000000000000000000000
c7c7c777c777c777e77e777e777e777e678c8c8c8c8c8c8c8787878878788788b7bb7b7b7b7bb7bb000000000000000000000000000000000000000000000000
c7c7c7c7c7c7c7c7e7ee7e7e7e7e7e7e67c8c8c8c8c8c8c88787877878788788b7777b7b7b7bb7bb000000000000000000000000000000000000000000000000
c777c777c7c7c7c7e7ee777e777e7e7e678c8c8c8c8c8c8c8787878887888788b7b7bb7b7b7bb7bb000000000000000000000000000000000000000000000000
c7c7c7c7c7c7c7c7e7ee7e7e77ee7e7e67c8c8c8c8c8c8c88787878878788788b7bb7b7b7b7bb7bb000000000000000000000000000000000000000000000000
c7c7c7c7c7c7c777e77e7e7e7e7e777e67777777777777778787877878788788b7bb7b777b77b77b000000000000000000000000000000000000000000000000
cccccccccccccccceeeeeeeeeeeeeeee66666666666666668888888888888888bbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77787777777877777778777777888777778787777787877777878777777c7777777c7777777c777777ccc7770000000000000000000000000000000000000000
7788877777888777778887777787877777787777777877777778777777ccc77777ccc77777ccc77777c7c7770000000000000000000000000000000000000000
77787777777877777778777777878777778787777787877777878777777c7777777c7777777c777777c7c7770000000000000000000000000000000000000000
77777777788888777778888777778777787778887788887777888877ccc7ccccc777ccccccc7cccc7777c7770000000000000000000000000000000000000000
7778877778777877787777877778877778777877777778777777787777c7c77cc777c77cc7c7c77c777cc7770000000000000000000000000000000000000000
778787777888887778777877777877777877788877778777777788777cc7c77cccccc77cccc7c77c777c77770000000000000000000000000000000000000000
7888887778777877787787777777777778787778777877777777787777c7c77cc77cc77c77c7c77c777777770000000000000000000000000000000000000000
77778777788888777878888877787777787778887788888777888877ccc7cccccccccccc77c7cccc777c77770000000000000000000000000000000000000000
ccccccccccccccccc777c777777ccccccccccccc888888cc7777777cc777c777cccccccc777ccccc000000000000000000000000000000000000000000000000
ccccccccccccccccc7c7c7c77c7ccccccccccccc8c88c8cc7c7c7c7cc7c7c7c7cccccccc7c7ccccc000000000000000000000000000000000000000000000000
ccc777ccc777c777c777c77777777ccccccccccc888888cc7777777cc777c777cccccccc777ccccc000000000000000000000000000000000000000000000000
ccc7c7ccc7c7c7c7cccccccccc7c7ccccccc7777888888cccccccccccccccccccccc888877cc8888000000000000000000000000000000000000000000000000
ccc7c7ccc7c7c7c7c777c777cc77777cccc777778c88c8cccc77777cc777c777ccc888887c788888000000000000000000000000000000000000000000000000
ccc777ccc777c777c7c7c7c7cccc7c7ccc77777788888888cc7c7c7cc7c7c7c7cc888888cc888888000000000000000000000000000000000000000000000000
ccccccccccccccccc7c7c7c7cccc777cc7777777ccccc8c8cc7c7c7cc777c777c8888888c8888888000000000000000000000000000000000000000000000000
ccccccccccccccccc777c777cccccccc77777777ccccc888cc77777ccccccccc8888888888888888000000000000000000000000000000000000000000000000
f777f7778888888f9999999fcccccccfdddddddfffffffffffffffffafafaaaf777f777f00000000000000000000000000000000000000000000000000000000
f7f7f7f78f8f8f8f9f9f9f9fcfcfcfcfdfdfdfdfff8888ffffccccfffaffffaf7f7f7f7f00000000000000000000000000000000000000000000000000000000
f7f7f7f78888888f9999999fcccccccfdddddddfff8ff8ffffcffcffafafaaff777f777f00000000000000000000000000000000000000000000000000000000
f777f777ffffffffffffffffffffffffffffffffff8888ffffccccffffffafffffffffff00000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaaaaf55555ff00000000000000000000000000000000000000000000000000000000
f777f777ffffffffffffffffffffffffffffffffff8888ffffccccffaaaaafffffdddfff00000000000000000000000000000000000000000000000000000000
f7f7f7f7ffffffffffffffffffffffffffffffffff8ff8ffffcffcffafafafffffdddfff00000000000000000000000000000000000000000000000000000000
f777f777ffffffffffffffffffffffffffffffffff8888ffffccccffafafafffffdddfff00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17777100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17777710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17777771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17777110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
060000000d050110571415716157181571a157250001c0070e00708007030070000700007010070100702007020070200702006020060040700407004070040700407004070040700407004072f2072d00700000
0001000015150151501515015150141501415012150101500d1500b15009150081500815008150081500715007150071500715003150011500015000150051000510005100051000510005100061000610006100
000100000635006350063500735008350093500b3500c3500f350113501a3501e350213502435026350293502c350303503335035350373501f3001e3001d3001c30019300153000f30000300000000000000000
001000003005030050300502b0502e0502e0502b0502b050260002600026000250002500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f0000160700807002070080700d070070700407002070000700007001070000700007000000020000200001000010000100000000000000000000000020000200000000000000000000000000000000000000
000100002a2502a25029250292502925029250292501b0501b0501c0501c0501c0501c0501c0502b2502d2502f250312503425038250392002c2002c2002c2002c20037200382000b20000200206002060000000
00090000190501905019050210502b0502f0502f0502f0502f0502f050194001940019400194002c4002e4002e4002e3003030031300323003330033300343003530000000000000000000000000000000000000
00030000231502515024150221501f1501b15013150051501910016100131000f1000b1001c1001b1001b1001a1001a100191001910019100191001b1001f1000000000000000000000000000000000000000000
000100000000026150221501d1501915015150111500e1500b15008150051500315001150001500c15016150121501215012150131501c1501f15022150221500000000000000000000000000000000000000000
00080000000002505025050250502e0502e0502e0502e05025050250502505029050290502905029050290502905029050290503800038000380003800038000380003800038000380003e0003e0003f00000000
00060000000000f1500f1500f1500f1500f1500815008150081500815008150081500310003100080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002000001885000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
