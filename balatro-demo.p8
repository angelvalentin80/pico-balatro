pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Globals
screen_width = 128
screen_height = 128
card_width = 8
card_height = 8
debug_draw_text = ""
hand_type_text = ""
draw_hand_gap = 4 
draw_special_cards_gap = 10
init_draw = true 
max_selected = 5
card_selected_count = 0
suits = {'H', 'D', 'C', 'S'}
sprite_index_lookup_table = {}
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
			effect = function()
				--TODO not finished
				if #selected_cards <= 2 then
					for card in all(selected_cards) do
						if card.rank == "A" do
							-- finish
						else
							-- finish
						end
					end
				end
			end,
			sprite_index = 160,
			description = "Increases the rank of two selected cards by 1",
			type = "Tarot"
		},
		{
			name = "Change to Hearts",
			price = 2,
			effect = function()
				-- TODO 
			end,
			sprite_index = 161,
			description = "Changes the suit of 3 selected cards to Hearts",
			type = "Tarot"
		},
		{
			name = "Change to Diamonds",
			price = 2,
			effect = function()
				-- TODO 
			end,
			sprite_index = 162,
			description = "Changes the suit of 3 selected cards to Diamonds",
			type = "Tarot"
		},
		{
			name = "Change to Clubs",
			price = 2,
			effect = function()
				-- TODO 
			end,
			sprite_index = 163,
			description = "Changes the suit of 3 selected cards to Clubs",
			type = "Tarot"
		},
		{
			name = "Change to Spades",
			price = 2,
			effect = function()
				-- TODO 
			end,
			sprite_index = 164,
			description = "Changes the suit of 3 selected cards to Spades",
			type = "Tarot"
		},
		{
			name = "Add 4 Mult",
			price = 2,
			effect = function()
				-- TODO 
			end,
			sprite_index = 165,
			description = "Gives two cards the ability to add 4 Mult when scored",
			type = "Tarot"
		},
		{
			name = "Add 30 Chips",
			price = 2,
			effect = function()
				-- TODO 
			end,
			sprite_index = 166,
			description = "Gives two cards the ability to add 30 Chips when scored",
			type = "Tarot"
		},
		{
			name = "Multiply Money by 2",
			price = 4,
			effect = function()
				-- TODO 
			end,
			sprite_index = 167,
			description = "Multiplies your money by 2 with the max being 20",
			type = "Tarot"
		},
		{
			name = "Delete Cards",
			price = 2,
			effect = function()
				-- TODO 
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
btn_play_hand_pos_y = 100
btn_discard_hand_sprite_index = 66
btn_discard_hand_pos_x = 80 
btn_discard_hand_pos_y = 100
btn_buy_sprite_index = 74

btn_go_next_sprite_index = 70
btn_go_next_pos_x = 20 
btn_go_next_pos_y = 50 
btn_reroll_sprite_index = 72
btn_reroll_pos_x = 20 
btn_reroll_pos_y = 70 

-- Game State
hand = {}
selected_cards = {}
shop_options = {}
scored_cards = {}
joker_cards = {}
tarot_cards = {}
joker_limit = 5
tarot_limit = 2
reroll_price = 5
hand_size = 8
score = 0
chips = 0
mult = 0
hands = 4
discards = 4
money = 4
round = 1
goal_score = 300
in_shop = false
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
	elseif btnp(5) and in_shop then
		go_next_button_clicked()
		buy_button_clicked()
		reroll_button_clicked()
	end

    -- Check keyboard
    --if stat(30) then
    --	end
end

function _draw()
    -- draw stuff
    cls()
	-- conditional draw
	if in_shop then
		draw_background()
		draw_score()
		draw_shop()
		draw_go_next_and_reroll_button()
		draw_shop_options()
	else
    	draw_background()
    	draw_hand()
		draw_play_discard_buttons()
		draw_chips_and_mult()
		draw_score()
		draw_hand_type(hand_type_text)
		draw_deck()
	end
	-- always draw
	draw_hands_and_discards()
	draw_money()
	draw_round_and_score()
	draw_joker_cards()
	draw_tarot_cards()
    draw_mouse(mx, my)
	test_draw_debug() -- TODO remove this
end

function score_hand()
	-- Score cards 
	for card in all(scored_cards) do
		chips = chips + card.chips
		mult = mult + card.mult
	end
	score_jokers()
	score = score + (chips * mult)
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
	goal_score = goal_score + 150
end

function win_state()
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
	card_id = 1
	base_deck = {}

	-- Set the sorting order		
	for i, card in pairs(ranks) do
    	card.order = 14 - i
	end

	-- Create deck
	for x=1,#ranks do
		for y=1,#suits do
			card_info = {
				card_id = card_id,	
				rank = ranks[x].rank,
				suit = suits[y],
				chips = ranks[x].base_chips,
				mult = 0,
				sprite_index = sprite_index_lookup_table[ranks[x]["rank"] .. suits[y]],
				order = ranks[x].order,
				-- Resettable params
				selected = false,
				pos_x = 0,
				pos_y = 0
			}
			add(base_deck, card_info)
			card_id = card_id + 1
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
	local sprite_index = 0	 

	-- Create deck
	for x=1,#ranks do
		for y=1,#suits do
			sprite_index_lookup_table[ranks[x]["rank"] .. suits[y]] = sprite_index
			sprite_index = sprite_index + 1
		end
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
	random_joker = rnd(special_cards["Jokers"])
	add(shop_options, random_joker)
	random_planet = rnd(special_cards["Planets"])
	add(shop_options, random_planet)
	random_tarot = rnd(special_cards["Tarots"])
	add(shop_options, random_tarot)
end

-- Graphics 
function draw_background()
    rectfill(0, 0, 128, 128, 3) 
end

function draw_hand()	
	draw_hand_start_x = 15	
	draw_hand_start_y = 80
	if init_draw then
		for x=1,#hand do
 	   		spr(hand[x].sprite_index, draw_hand_start_x, draw_hand_start_y) 
			hand[x].pos_x = draw_hand_start_x
			hand[x].pos_y = draw_hand_start_y
			draw_hand_start_x = draw_hand_start_x + card_width + draw_hand_gap
		end
		init_draw = false
	else
		for x=1,#hand do
 	   		spr(hand[x].sprite_index, hand[x].pos_x, hand[x].pos_y) 
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
		if card_selected_count == 4 then debug_draw_text = "" end
	else
		debug_draw_text = "You can only select 5 \ncards at a time"
	end
end

function draw_play_discard_buttons()
	spr(btn_play_hand_sprite_index, btn_play_hand_pos_x, btn_play_hand_pos_y, 2, 2)
	spr(btn_discard_hand_sprite_index, btn_discard_hand_pos_x, btn_discard_hand_pos_y, 2, 2)
end

function draw_chips_and_mult()
	print(chips .. " X " .. mult, 2, 50, 7)
end

function draw_score()
	print("Score:" .. score, 2, 30, 7)
end

function draw_hand_type()
	print(hand_type_text, 45, 55, 7)	
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
	print("Round:" .. round, 2, 10, 7)
	print("Goal Score:" .. goal_score, 2, 20, 7)
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
	draw_joker_start_x = 55	
	draw_joker_start_y = 5 
	for joker in all(joker_cards) do
   		spr(joker.sprite_index, draw_joker_start_x, draw_joker_start_y)
		draw_joker_start_x = draw_joker_start_x + card_width + draw_hand_gap 
	end
	print(#joker_cards.. "/" .. joker_limit, draw_joker_start_x, draw_joker_start_y, 7)
end

function draw_tarot_cards()
	draw_tarot_start_x = 82	
	draw_tarot_start_y = 20 
	for tarot in all(tarot_cards) do
   		spr(tarot.sprite_index, draw_tarot_start_x, draw_tarot_start_y)
		draw_tarot_start_x = draw_tarot_start_x + card_width + draw_hand_gap 
	end
end

-- Inputs
function hand_collision()
	-- Check if the mouse is colliding with a card in our hand 
	for x=1, #hand do
		if mx >= hand[x].pos_x and mx < hand[x].pos_x + card_width and
			my >= hand[x].pos_y and my < hand[x].pos_y + card_height then
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
			debug_draw_text = ""
			if hands == 0 then
				lose_state()
			end
		end
	end
end

function discard_button_clicked()
	if mouse_sprite_collision(btn_discard_hand_pos_x, btn_discard_hand_pos_y, btn_width, btn_height) and #selected_cards > 0 and discards > 0 then
		for card in all(selected_cards) do
			del(hand, card)	
			del(selected_cards, card)
		end
		deal_hand(shuffled_deck, card_selected_count)
		init_draw = true
		card_selected_count = 0
		discards = discards - 1
		debug_draw_text = ""
	end
end

function go_next_button_clicked()
	if mouse_sprite_collision(btn_go_next_pos_x, btn_go_next_pos_y, btn_width, btn_height)	and in_shop == true then
		in_shop = false			
		shop_options = {}
		debug_draw_text	= ""
		reroll_price = 5
		score = 0
	end
end

function reroll_button_clicked()
	if mouse_sprite_collision(btn_reroll_pos_x, btn_reroll_pos_y, btn_width, btn_height) and in_shop == true and money >= reroll_price then
		money = money - reroll_price
		shop_options = {}
		add_cards_to_shop()
		reroll_price = reroll_price + 1
	elseif mouse_sprite_collision(btn_reroll_pos_x, btn_reroll_pos_y, btn_width, btn_height) and in_shop == true and money < reroll_price then
		debug_draw_text = "You don't have enough\n money to reroll.\n Get your money up."
	end
end

function buy_button_clicked()
	for special_card in all(shop_options) do
		if mouse_sprite_collision(special_card.pos_x, special_card.pos_y + card_height, card_width, card_height) and in_shop == true and money >= special_card.price then
			money = money - special_card.price
			-- Joker
			if special_card.type == "Joker" and #joker_cards < joker_limit then
				add(joker_cards, special_card)
				del(shop_options, special_card)
			elseif special_card.type == "Joker" and #joker_cards == joker_limit then 
				debug_draw_text = "You have reached \nthe max amount \nof jokers"
			end

			-- Tarot 
			if special_card.type == "Tarot" then
				add(tarot_cards, special_card)
				del(shop_options, special_card)
			end

			-- Planet 
			if special_card.type == "Planet" then	
				special_card.effect()
				del(shop_options, special_card)
			end
		elseif mouse_sprite_collision(special_card.pos_x, special_card.pos_y + card_height, card_width, card_height) and in_shop == true and money < special_card.price then
			debug_draw_text = "You don't have enough\n money to buy this.\n Get your money up."
		end
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

-- TEST
function test_draw_debug()
	print(debug_draw_text, 30, 35, 7)
end

function test_draw_table(table)
	for card in all(table) do
		debug_draw_text = debug_draw_text .. " " .. card.rank .. card.suit
	end
end

__gfx__
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
7778887777799977777ccc777775557778777887797779977c777cc775777557778888777799997777cccc777755557778888887799999977cccccc775555557
778778777797797777c77c777757757778788777797997777c7cc7777575577778777787797777977c7777c775777757777778777777797777777c7777777577
78888887799999977cccccc77555555778877777799777777cc777777557777778777787797777977c7777c775777757777778777777797777777c7777777577
78777787797777977c7777c77577775778888777799997777cccc7777555577778778787797797977c77c7c77577575778777877797779777c777c7775777577
78777787797777977c7777c77577775778778877797799777c77cc777577557778777877797779777c777c777577757778777877797779777c777c7775777577
78777787797777977c7777c77577775778777887797779977c777cc775777557778887877799979777ccc7c777555757778888777799997777cccc7777555577
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
78788887797999977c7cccc77575555778888887799999977cccccc77555555778888887799999977cccccc77555555778888887799999977cccccc775555557
78787787797977977c7c77c77575775778777787797777977c7777c77577775778777787797777977c7777c77577775778777787797777977c7777c775777757
78787787797977977c7c77c77575775778777787797777977c7777c77577775778888887799999977cccccc7755555577777778777777797777777c777777757
78787787797977977c7c77c77575775778888887799999977cccccc77555555778777787797777977c7777c7757777577777778777777797777777c777777757
78787787797977977c7c77c7757577577777778777777797777777c77777775778777787797777977c7777c7757777577777778777777797777777c777777757
78788887797999977c7cccc7757555577777778777777797777777c77777775778888887799999977cccccc7755555577777778777777797777777c777777757
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
7778887777799977777ccc777775557778888887799999977cccccc77555555777778877777799777777cc777777557778888887799999977cccccc775555557
778777777797777777c777777757777778777777797777777c777777757777777778787777797977777c7c77777575777777778777777797777777c777777757
78777777797777777c7777777577777778888887799999977cccccc775555557778778777797797777c77c77775775777777778777777797777777c777777757
78888887799999977cccccc7755555577777778777777797777777c77777775778888887799999977cccccc775555557778888877799999777ccccc777555557
78777787797777977c7777c7757777577777778777777797777777c777777757777778777777797777777c77777775777777778777777797777777c777777757
78888887799999977cccccc77555555778888887799999977cccccc775555557777778777777797777777c777777757778888887799999977cccccc775555557
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
778888877799999777ccccc777555557000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78777787797777977c7777c775777757000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777778877777799777777cc777777557000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
778887777799977777ccc77777555777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78877777799777777cc7777775577777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78888887799999977cccccc775555557000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccceeeeeeeeeeeeeeee678c8c8c8c8c8c8c8888888888888888bbbbbbbbbbbbbbbb8aaa8a8a0000000000000000000000000000000000000000
cccccccccccccccce777e777e777eeee67c8c8c8c8c8c8c88887778877777788bb77777bb77777bb888a8a8a0000000000000000000000000000000000000000
c777c7cc777c7c7ce7e7ee7ee7eeeeee678c8c8c8c8c8c8c8878888878888788bb7bbb7bb7bbbbbb8a8a8a8a0000000000000000000000000000000000000000
c7c7c7cc7c7c7c7ce7e7ee7ee777eeee67c8c8c8c8c8c8c88788888878888788bb77777bb777bbbb888a888a0000000000000000000000000000000000000000
c777c7cc777c7c7ce7e7ee7eeee7e77e678c8c8c8c8c8c8c8788778878888788bb7b7bbbb7bbbbbbaaaaaaaa0000000000000000000000000000000000000000
c7ccc7cc7c7cc7cce7e7ee7eeee7eeee67c8c8c8c8c8c8c88788878878888788bb7bb7bbb7bbbbbbaa8a8aaa0000000000000000000000000000000000000000
c7ccc77c7c7cc7cce777e777e777eeee678c8c8c8c8c8c8c8777778877777788bb7bbb7bb77777bbaaa8aaaa0000000000000000000000000000000000000000
cccccccccccccccceeeeeeeeeeeeeeee67c8c8c8c8c8c8c88888888888888888bbbbbbbbbbbbbbbbaaa8aaaa0000000000000000000000000000000000000000
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
000100000000005050090503e05039050370503505033050310502e0502c050290503d0503a05037050350503405032050300502f0502d0502b05029050270502405022050000000000000000000000000000000
