pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Globals
-- Game State
hand_size = 8
draw_hand_start_x = 15	
draw_hand_start_y = 80
draw_hand_gap = 12

-- Input
mx = 0
my = 0

-- Gameplay
function _init()
    -- initialize data
    poke(0x5F2D, 0x7)
    end

function _update()
    --register inputs
    mx = stat(32)
    my = stat(33)
    -- TODO make mouse less jumpy

    -- Check mouse buttons
    mb = stat(34)

    -- Check keyboard
    if stat(30) then
        key = stat(31) -- Get the last key pressed
    	if key == "l" then
    		?"LOSERRR"
	end
    	if key == "w" then	
        	?"WINNERRR"
	end
    end

    end

function _draw()
    -- draw stuff
    cls()
    draw_background()
    draw_hand(hand)
    draw_mouse(mx, my)
    end

-- Deck
function create_base_deck()
	suits = {'H', 'D', 'C', 'S'}
	ranks = {
		{rank = 'A', base_score = 11},
		{rank = 'K', base_score = 10},
		{rank = 'Q', base_score = 10},
		{rank = 'J', base_score = 10},
		{rank = '10', base_score = 10},
		{rank = '9', base_score = 9},
		{rank = '8', base_score = 8},
		{rank = '7', base_score = 7},
		{rank = '6', base_score = 6},
		{rank = '5', base_score = 5},
		{rank = '4', base_score = 4},
		{rank = '3', base_score = 3},
		{rank = '2', base_score = 2},
		}	
		
	sprite_index = 0
	card_id = 1
	base_deck = {}
	for x=1,#ranks do
		for y=1,#suits do
			card_info = {
				card_id = card_id,	
				rank = ranks[x].rank,
				suit = suits[y],
				score = ranks[x].base_score,
				mult = 0,
				sprite_index = sprite_index
			}
			add(base_deck, card_info)
			card_id = card_id + 1
			sprite_index = sprite_index + 1
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

function deal_hand(shuffled_deck, hand_size)
	hand = {}
	if #shuffled_deck < hand_size then
		return shuffled_deck	
	else
		for x=1,hand_size do
			add(hand, shuffled_deck[x])				
			del(shuffled_deck, shuffled_deck[x])
			end
		return hand
		end
	end

function print_hand(hand)
    -- TEST 
    hand_as_string = ""
    for x=1,#hand do 
        hand_as_string = hand_as_string .. hand[x].rank .. hand[x].suit .. " "
        --.rank
        --.suit
        end
    ?hand_as_string
    end

-- Graphics 
function draw_background()
    rectfill(0, 0, 128, 128, 3) 
    end

function draw_hand(hand)	
	for x=1,#hand do
    	spr(hand[x].sprite_index, draw_hand_start_x, draw_hand_start_y) 
		draw_hand_start_x = draw_hand_start_x + draw_hand_gap
		end
	end

function draw_mouse(x, y)
	spr(192, x, y)
	end

-- IDK 
base_deck = create_base_deck()
shuffled_deck = shuffle_deck(base_deck)
hand = deal_hand(shuffled_deck, hand_size)


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
