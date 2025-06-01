pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Globals
debugmouse=false
screen_width = 128
screen_height = 128
card_width = 8
card_height = 8
error_message = ""
hand_type_text = ""
draw_hand_gap = 4 
draw_special_cards_gap = 10
init_draw = true 
sparkles = {}
max_selected = 5
card_selected_count = 0
suits = {'h', 'd', 'c', 's'}
suit_colors = {s=5,c=12,h=8,d=9}
suit_sprites = {s=16,c=17,h=18,d=19}
ranks = {
	{rank = 'a', base_chips = 11},
	{rank = 'k', base_chips = 10},
	{rank = 'q', base_chips = 10},
	{rank = 'j', base_chips = 10},
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

-- object references
joker_cards = {}
tarot_cards = {}

hand_types = {
	["flush five"] = {base_chips = 160, base_mult = 16, level = 1},
	["flush house"] = {base_chips = 140, base_mult = 14, level = 1},
	["five of a kind"] = {base_chips = 120, base_mult = 12, level = 1},
	["royal flush"] = {base_chips = 100, base_mult = 8, level = 1},
	["straight flush"] = {base_chips = 100, base_mult = 8, level = 1},
	["four of a kind"] = {base_chips = 60, base_mult = 7, level = 1},
	["full house"] = {base_chips = 40, base_mult = 4, level = 1},
	["flush"] = {base_chips = 35, base_mult = 4, level = 1},
	["straight"] = {base_chips = 30, base_mult = 4, level = 1},
	["three of a kind"] = {base_chips = 30, base_mult = 3, level = 1},
	["two pair"] = {base_chips = 20, base_mult = 2, level = 1},
	["pair"] = {base_chips = 10, base_mult = 2, level = 1},
	["high card"] = {base_chips = 5, base_mult = 1, level = 1}
}
hand_types_copy = {}
-- animations
function pause(frames)
	while frames>0 do
		frames -= 1
		yield()
	end
end
function add_money(i, card)
	if(i == 0) return pause(1)
	money += i
	sfx(sfx_add_money)
	add_sparkle(35,card)
	pause(7)
end
function multiply_mult(i, card)
	if(i == 0) return pause(1)
	mult *= i
	sfx(sfx_multiply_mult)
	add_sparkle(34,card)
	pause(7)
end
function add_mult(i, card)
	if(i == 0) return pause(1)
	mult += i
	sfx(sfx_add_mult)
	add_sparkle(33,card)
	pause(5)
end
function add_chips(i, card)
	if(i == 0) return pause(1)
	chips += i
	sfx(sfx_add_chips)
	add_sparkle(32,card)
	pause(5)
end

-- sparkles
function add_sparkle(sprite_index,source)
	if(source==nil or max(0,source.pos_y) < 1)return
	add(sparkles, {
		x=source.pos_x,
		y=source.pos_y,
		sprite_index=sprite_index,
		frames=8
	})
end

function draw_sparkles()
	pal() -- all others normal
	palt(0x0010) -- green transparent
	for i=#sparkles,1,-1 do
		sp=sparkles[i]
		spr(sp.sprite_index,sp.x,sp.y)
		if sp.frames>0 then
			sp.frames -= 1
			sp.y -= 1
		else
			deli(sparkles,i)
		end
	end
end

-- button object for clicks
button_obj={
	pos_x=0, pos_y=0,
	sprite_index=0,
	height=16, width=16,
}
function button_obj:new(obj)
	return setmetatable(obj, {
		__index=self
	})
end
function button_obj:draw()
	self:draw_at(
			self.pos_x,self.pos_y)
end
function button_obj:draw_at(x,y)
	spr(self.sprite_index, x, y, 
		self.width/8, 
		self.height/8)
end
function button_obj:moused()
	return mouse_sprite_collision(
		self.pos_x, self.pos_y,
		self.width, self.height)
end

textbutton_obj=button_obj:new({
	height=9,color=0
})
function textbutton_obj:new(obj)
	obj.height=9
	obj.width=#(obj.text)*4 + 4
	return setmetatable(obj, {
		__index=self
	})
end

function textbutton_obj:draw_at(x,y)
	rectfill(x, y, 
		x+self.width-1, 
		y+self.height-1, 
		self.color)
	print(self.text,x+2,y+2,7)
end


-- abstract item object 
-- can be drawn on screen and reset
item_obj={
	type="card",
	-- default size stuff
	width=card_width,
	height=card_height,
	-- resettable params
	selected=false,
	pos_x=0,
	pos_y=0,
	from_x=nil,
	from_y=nil,
	frames=0,
	picked_up=false
}
picked_up_item=nil
function item_obj:new(obj) 
	return setmetatable(obj, {
		__index=self
	})
end
function item_obj:place(x,y,frames) 
	if max(0,frames) > 0 then
		self.from_x = self.pos_x
		self.from_y = self.pos_y
		self.frames = frames
	end
	self.pos_x=x
	self.pos_y=y
end
function item_obj:reset()
	self.selected=false
	self.pos_x=btn_deck.pos_x
	self.pos_y=btn_deck.pos_y
end
function item_obj:draw()
	if(picked_up_item==self)return
	-- animation
	if self.frames > 0 then
		self.frames -= 1
		if self.frames == 0 then
			self.from_x = nil
			self.from_y = nil
		else
			self.from_x += (self.pos_x-self.from_x) / self.frames
			self.from_y += (self.pos_y-self.from_y) / self.frames
			self:draw_at(self.from_x, self.from_y)
			return
		end
	end
	-- no animation
	self:draw_at(self.pos_x,self.pos_y)
end

-- draw at absolute position
-- regardless of obj position
function item_obj:draw_at(x,y)
	spr(self.sprite_index, x, y)
end

function item_obj:moused(morex,morey)
	morex=min(morex) -- default 0
	morey=min(morey)
	return mouse_sprite_collision(
		self.pos_x,
		self.pos_y,
		self.width+morex,
		self.height+morey) 
end

-- called when mouse is clicked
-- and held
function item_obj:pickup()
	-- record start state of
	-- object and mouse
	self.picked_up = {
		src_x=self.pos_x,
		src_y=self.pos_y,
		mx=mx,
		my=my,
		offx= mx-self.pos_x,
		offy= my-self.pos_y,
		moved=false
	}
	picked_up_item=self
end

-- detect if the mouse moves
-- more than 1 pixel between
-- mouse_down and mouse_up
function item_obj:detect_moved()
	if(not self.picked_up) return
	if(self.picked_up.moved) return
	if abs(mx-self.picked_up.mx)>1
		or abs(my-self.picked_up.my)>1
		then
			self.picked_up.moved=true
	end
end

function item_obj:drop()
	if(picked_up_item!=self) return
	if(not self.picked_up) return
	self:drop_at(
		mx-self.picked_up.offx,
		my-self.picked_up.offy
	)
	self.picked_up=nil
	picked_up_item=nil
end

-- fallback: leave it where it lies
function item_obj:drop_at(px,py)
	self.pos_x=px
	self.pos_y=py
end

-- utility functions
function do_nothing()
end

-- playing cards
card_obj=item_obj:new({
	type = "card",
	bgtile = 15,
	height = 15, -- scant 2 tiles
	effect_chips = 0,
	mult = 0,
	pos_x = 0,
	pos_y = 0,
	when_held_in_hand = do_nothing,
	when_held_at_end = do_nothing,
	effect = do_nothing,
	card_effect = do_nothing
})
function card_obj:reset()
	self.selected=false
	self.pos_x=0
	self.pos_y=0
end
function card_obj:draw_at(x,y)
	pal()
	rectfill(x-1,y-1,x-2+self.width,y-2+self.height,0)
	palt(11,true)
	pal(8,suit_colors[self.suit])
	spr(self.bgtile,x,y,1,2)
	-- overlay rank
	spr(self.sprite_index, x, y)
	-- if not wild, overlay suit
 if self.bgtile != 44 then
		spr(suit_sprites[self.suit],x,y+8)
	end
	pal()
end

function card_obj:draw_at_mouse()
	if (not self.picked_up) return
	self:draw_at(
		mx-self.picked_up.offx,
		my-self.picked_up.offy
	)
end

-- rank moving
function card_obj:set_rank_by_order(o)
	for r in all(ranks) do
		if r.order == o then
			return self:set_rank(r)
		end
	end
	assert(false) -- rank not found
end

function card_obj:set_rank(r)
	self.rank = r.rank
	self.sprite_index = r.sprite_index
	self.order = r.order
	self.chips = r.base_chips 
end

function card_obj:plus_order(d)
	return ((self.order-d-1) % 13) + 1
end

function card_obj:add_rank(d)
	new_order=self:plus_order(d)
	self:set_rank_by_order(new_order)
end

function card_obj:is_face()
	if(has_joker('pareidolia')) return true
	return contains({'k','j','q'},self.rank)
end

function card_obj:matches_suit(other)
	-- 44=wild card
	if(other.bgtile==44)return true
	-- compare normally
	return self:is_suit(other.suit)
end

function card_obj:is_suit(target)
	-- 44=wild card
	if(self.bgtile==44)return true
	if has_joker('smeared joker') then
		if target=='s' or target=='c' then
			return self.suit=='s' or self.suit=='c'
		else
			return self.suit=='d' or self.suit=='h'
		end
	end
	return self.suit == target
end

-- special cards
special_obj=item_obj:new({})
-- description shown when mouse
-- is over the object
function special_obj:describe()
	-- window appears at bottom
	rectfill(0,98,127,127,self.bg)
	-- print first letter of type on right side
	print("\^p"..self.type[1],120,99,self.fg)
	spr(self.sprite_index,3,99)
	print(self.name,card_width+8,99,self.fg)
	if type(self.description) == "string" then
		print(self.description,1,110,self.fg)
	else
		print(self:description(),1,110,self.fg)
	end
	print("\^p"..self.type[1],120,99,self.fg)
end

function special_obj:draw_at(x,y)
	-- draw icon obviously
	spr(self.sprite_index, x, y)
	-- draw sell icon if owned
	if in_shop and contains(shop_options,self) then
		spr(btn_buy_sprite_index, x , y+self.height)
		print("$"..self.price, x + self.width, y + self.height + 1, 7)
	elseif contains(self.ref,self) then
		spr(btn_sell_sprite_index, x - self.width, y)
		print("$"..calculate_sell_price(self.price), x - card_width, y + card_height + 1, 7)
		if self.usable then
			spr(btn_use_sprite_index, x, y + self.height)
		end
	end
end

joker_obj=special_obj:new({
			type = "Joker",bg=0,fg=7,
			ref = joker_cards,
			effect=function(self) end,
			card_effect=function(self,card) end
})
tarot_obj=special_obj:new({
			type = "Tarot", bg=15, fg=1,
			ref = tarot_cards, usable=true
})
planet_obj=special_obj:new({
			type = "Planet", bg=12, fg=7,
			effect=function(self)
				level_up_hand_type(self.hand,self.mult,self.chips)
			end,
			description=function(self)
				return "levels up " .. self.hand ..
					"\nadds +" .. tostr(self.mult) ..
					" mult and +" .. tostr(self.chips) ..
					" chips"
			end
})

-- common function to add an effect
-- to cards.  pass in the maximum
-- number of cards and a function
-- that modifies one individual card.
function card_enhancement(qty,body)
	return function(self)
		-- consider checking for 0 if
		-- it's no longer handled elsewhere
		if #selected_cards > qty then
			sfx(sfx_error_message)
			error_message = "too many cards selected"
			return
		end
		for card in all(selected_cards) do
			card.selected = false
			card.pos_y += 10
			body(card, self)
		end
		card_selected_count = 0
		del(tarot_cards, self)
		init_draw = true
	end
end

-- all change-suit tarots are the same
function suit_change(new_suit)
	return card_enhancement(3, function(card)
			card.suit = new_suit 
	end)
end

-- shop inventory
special_cards = {
	Jokers = {
		joker_obj:new({
			name = "joker",
			price = 2,
			effect = function(self)
				add_mult(4, self)
			end,
			sprite_index = 128, 
			description = "+4 mult"
		}),
		joker_obj:new({
			name = "Add 8 Mult",
			price = 3,
			effect = function(self)
				add_mult(8, self)
			end,
			sprite_index = 129, 
			description = "+8 mult"
		}),
		joker_obj:new({
			name = "raised fist",
			price = 3,
			effect = function(self)
				min_rank=99
				for card in all(hand) do
					if(not card.selected) min_rank=min(min_rank,card.chips)
				end
				add_mult(2*min_rank, self)
			end,
			sprite_index = 130, 
			description = "adds double the rank of lowest\nranked card held in hand\nto mult"
		}),
		joker_obj:new({
			name = "Add Random Mult",
			price = 4,
			effect = function(self)
				add_mult( flr(rnd(23), self) )
			end,
			sprite_index = 131, 
			description = "adds a random amount of mult.\nlowest being 0, highest being 25",
		}),
		joker_obj:new({
			name = "Times 1.5 Mult",
			price = 6,
			effect = function(self)
				multiply_mult(1.5, self)
			end,
			sprite_index = 132, 
			description = "Multiplies your mult by 1.5",
		}),
		joker_obj:new({
			name = "photograph",
			price = 5,
			card_affected=nil,
			card_effect=function(self,card)
				if self.card_affected==nil and card:is_face() then
					self.card_affected=card
				end
				if self.card_affected==card then
					multiply_mult(2, card)
					add_sparkle(34,self,9)
				end
			end,
			effect = function(self)
				self.card_affected=nil
			end,
			sprite_index = 133, 
			description = "first played face card gives\nx2 mult when scored",
		}),
		joker_obj:new({
			name = "Times 3 Mult",
			price = 8,
			effect = function(self)
				multiply_mult(3, self)
			end,
			sprite_index = 134, 
			description = "Multiplies your mult by 3",
		}),
		joker_obj:new({
			name = "odd todd",
			price = 4,
			card_effect = function(self, card)
				if (contains({'a','3','5','7','9'},card.rank)) then
					add_chips(31, card)
				end
			end,
			sprite_index = 140, 
			description = "adds 31 chips for each card with odd rank",
		}),
		joker_obj:new({
			name = "scary face",
			price = 4,
			card_effect = function(self, card)
				if card:is_face() then
					add_chips(30, card)
				end
			end,
			sprite_index = 142, 
			description = "played face cards give +30 \nchips when scored"
		}),
		joker_obj:new({
			name = "scholar",
			price = 4,
			card_effect = function(self, card)
				if card.rank == 'a' then
					add_chips(20, card)
					add_chips(4, card)
				end
			end,
			sprite_index = 141, 
			description = "played aces give +20 chips\nand +4 mult when scored"
		}),
		joker_obj:new({
			name = "even steven",
			price = 4,
			card_effect = function(self, card)
				if contains({'2','4','6','8','10'},card.rank) then
					add_mult(4, card)
				end
			end,
			sprite_index = 128,
			description = "+4 mult for cards with even-numbered rank"
		}),
		joker_obj:new({
			name = "gluttonous joker",
			price = 5,
			card_effect = function(self, card)
				if card:is_suit('c') then
					add_mult(3, card)
				end
			end,
			sprite_index = 179,
			description = "played cards with club suit\ngive +3 mult when scored"
		}),
		joker_obj:new({
			name = "lusty joker",
			price = 5,
			card_effect = function(self, card)
				if card:is_suit('h') then
					add_mult(3, card)
				end
			end,
			sprite_index = 177,
			description = "played cards with heart suit\ngive +3 mult when scored"
		}),
		joker_obj:new({
			name = "wrathful joker",
			price = 5,
			card_effect = function(self, card)
				if card:is_suit('s') then
					add_mult(3, card)
				end
			end,
			sprite_index = 180,
			description = "played cards with spade suit\ngive +3 mult when scored"
		}),
		joker_obj:new({
			name = "greedy joker",
			price = 5,
			card_effect = function(self, card)
				if card:is_suit('d') then
					add_mult(3, card)
				end
			end,
			sprite_index = 178,
			description = "played cards with diamond suit\ngive +3 mult when scored"
		}),
		joker_obj:new({
			name = "Add 60 Chips",
			price = 3,
			effect = function(self)
				add_chips(60, self)
			end,
			sprite_index = 136, 
			description = "Adds 60 to your chips",
		}),
		joker_obj:new({
			name = "Add 90 Chips",
			price = 4,
			effect = function(self)
				add_chips(90, self)
			end,
			sprite_index = 137, 
			description = "Adds 90 to your chips",
		}),
		joker_obj:new({
			name = "Add Random Chips",
			price = 5,
			effect = function(self)
				local chip_options = {}
				local step = 10 
				local amount = 0
				while (amount <= 150) do
					add(chip_options, amount)
					amount = amount + step
				end
				add_chips(rnd(chip_options),self)
			end,
			sprite_index = 138, 
			description = "adds a random amount of chips.\nlowest being 0, highest being 150",
		}),
		joker_obj:new({
			name="pareidolia",
			price=5,
			-- effect in card_obj:is_face
			sprite_index=182,
			description = "all cards count as face cards"
		}),
		joker_obj:new({
			name="smeared joker",
			price=7,
			-- effect in card_obj:is_suit
			sprite_index=181,
			description = "clubs and spades are the same suit.\nhearts and diamonds are the same suit."
		}),
		joker_obj:new({
			name="four fingers",
			price=7,
			-- effect in contains_flush
			sprite_index=183,
			description = "all flushes and straights can\nbe made with 4 cards."
		}),
	},
	Planets = {
		planet_obj:new({
			name = "king neptune",
			price = 5,
			hand = "royal flush",
			chips = 50,
			mult = 5,
			sprite_index = 153,
		}),
		planet_obj:new({
			name = "neptune",
			price = 5,
			hand = "straight flush",
			chips=40, mult=4,
			sprite_index = 152,
		}),
		planet_obj:new({
			name = "mars",
			price = 4,
			hand = "four of a kind",
			chips=30, mult=3,
			sprite_index = 151,
		}),
		planet_obj:new({
			name = "earth",
			price = 3,
			hand = "full house",
			chips=25, mult=2,
			sprite_index = 150,
		}),
		planet_obj:new({
			name = "jupiter",
			price = 3,
			hand = "flush",
			chips=15, mult=2,
			sprite_index = 149,
		}),
		planet_obj:new({
			name = "saturn",
			price = 3,
			hand = "straight",
			chips=30, mult=3,
			sprite_index = 148,
		}),
		planet_obj:new({
			name = "venus",
			price = 2,
			hand = "three of a kind",
			chips=20, mult=2,
			sprite_index = 147,
		}),
		planet_obj:new({
			name = "uranus",
			price = 2,
			hand = "two pair",
			chips=20, mult=1,
			sprite_index = 146,
		}),
		planet_obj:new({
			name = "mercury",
			price = 1,
			hand = "pair",
			chips=15, mult=1,
			sprite_index = 145,
		}),
		planet_obj:new({
			name = "pluto",
			price = 1,
			hand = "high card",
			chips=10, mult=1,
			sprite_index = 144,
		})
	},
	Tarots = {
		tarot_obj:new({
			name = "the devil",
			price = 2,
			effect = card_enhancement(1,function(card,self)
				card.bgtile = 45
				card.when_held_in_hand = do_nothing
				card.when_held_at_end = function(c)
					add_money(3,c)
				end
			end),
			sprite_index = 169,
			description = "converts 1 card into a\ngold card, which grants $3 if\ncard is in hand at end of round",
		}),
		tarot_obj:new({
			name = "the chariot",
			price = 2,
			effect = card_enhancement(1,function(card,self)
				card.bgtile = 46
				card.when_held_in_hand = function(c)
					multiply_mult(1.5,c)
				end
				card.when_held_at_end = do_nothing
			end),
			sprite_index = 170,
			description = "converts 1 card into a\nsteel card, which grants x1.5 mult \nif card is left in hand",
		}),
		tarot_obj:new({
			name = "the lovers",
			price = 2,
			effect = card_enhancement(1,function(card,self)
				card.bgtile = 44
				card.when_held_in_hand = do_nothing
				card.when_held_at_end = do_nothing
			end),
			sprite_index = 169,
			description = "converts 1 card into a\nwild card, which matches\nevery suit",
		}),
		tarot_obj:new({
			name = "strength",
			price = 2,
			effect = card_enhancement(2,function(card,self)
				card:add_rank(1)
				sort_by_rank_decreasing(hand)
			end),
			sprite_index = 160,
			description = "increases the rank of two\nselected cards by 1",
		}),
		tarot_obj:new({
			name = "the sun",
			price = 2,
			effect = suit_change("h"),
			sprite_index = 161,
			description = "changes the suit of 3 selected \ncards to hearts",
		}),
		tarot_obj:new({
			name = "the star",
			price = 2,
			effect = suit_change("d"),
			sprite_index = 162,
			description = "changes the suit of 3 selected \ncards to diamonds",
		}),
		tarot_obj:new({
			name = "the moon",
			price = 2,
			effect = suit_change("c"),
			sprite_index = 163,
			description = "changes the suit of 3 selected \ncards to clubs",
		}),
		tarot_obj:new({
			name = "the world",
			price = 2,
			effect = suit_change("s"),
			sprite_index = 164,
			description = "changes the suit of 3 selected \ncards to spades",
		}),
		tarot_obj:new({
			name = "the empress",
			price = 2,
			effect = card_enhancement(2,function(card,self)
				card.bgtile = 14
				card.effect_chips = 0 
				card.mult = 4
				card.when_held_in_hand = do_nothing
			end),
			sprite_index = 165,
			description = "causes up to two cards to add\n4 mult when scored",
		}),
		tarot_obj:new({
			name = "the hierophant",
			price = 2,
			effect = card_enhancement(2,function(card,self)
				card.bgtile = 13
				card.effect_chips = 30 
				card.mult = 0
				card.when_held_in_hand = do_nothing
				card.when_held_at_end = do_nothing
			end),
			sprite_index = 166,
			description = "causes up to two cards to add\n30 chips when scored",
		}),
		tarot_obj:new({
			name = "the hermit",
			price = 4,
			effect = function(tarot)
				if money >= 20 then
					add_money(20,tarot)
				else
					add_money(money,tarot)
				end
			end,
			sprite_index = 167,
			description = "Multiplies your money by\n2 with the max being 20",
		}),
		tarot_obj:new({
			name = "the hanged man",
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
			description = "Deletes two selected\ncards from the deck",
		})
	}
}

function has_joker(name)
	for j in all(joker_cards) do
		if(j.name==name) return j
	end
	return false
end

-- if set, then resume this
-- coroutine in main loop
animation=cocreate(print)

-- Special object to support full 32-bit integers
-- should work up to 2 billion
--
bigscore = {
}

function bigscore:new(val)
	if type(val) == 'number' then
		obj = {v = val >> 16}
	else -- copy from object
		obj = val
	end
	-- works for + and *, not >=
	return setmetatable(obj, {
		__index=self,
		__add=self.__add,
		__mul=self.__mul
	})
end

function bigscore:str()
	return tostr(self.v,2)
end

-- infinity object, for when the
-- amount flips into the negative
naneinf = {}
function naneinf:new(...)
	return setmetatable({v=-1}, {
		__index=self,
		__add=self.__add,
		__mul=self.__mul
	})
end

function naneinf:str() return "naneinf" end
function naneinf:__add(other) return self end
function naneinf:__mul(other) return self end
function naneinf:greater_or_equal(other) return true end

-- allow mixing with ints
-- in some math operations
function bigscore:__add(other)
	local result
	if type(other) == 'number' then
		result= bigscore:new({v=self.v+(other>>16)})
	else
		if(other.v<0) return naneinf:new()
		result= bigscore:new({v=self.v+other.v})
	end
	if(result.v<0) return naneinf:new()
	return result
end

function bigscore:__mul(other)
	local result
	if type(other) == 'number' then
		result= bigscore:new({v=self.v*other})
	else
		result= bigscore:new({v=self.v*(other.v<<16)})
	end
	if result.v < 0 then
		return naneinf:new()
	end
	return result
end

function bigscore:greater_or_equal(other)
	if type(other) == 'number' then
		return self.v >= (other>>16)
	elseif type(other) == 'table' then
		return self.v >= other.v
	end
end

-- unit tests for score stuff
function assert_score(actual,expected)
	if actual:str() != expected then
		cls()
		print("expected \#3"..expected)
		print("     was \#8"..actual:str())
		assert(false)
	end
end

assert_score( (bigscore:new(300) + 300), "600" )
assert_score( (bigscore:new(300) + bigscore:new(300)), "600" )
assert_score( (bigscore:new(300) * 1.5), "450" )
assert_score( (bigscore:new(300) * bigscore:new(2)), "600" )
assert_score( (bigscore:new(300) * 300), "90000" )
assert_score( (bigscore:new(300) * bigscore:new(300)), "90000" )
assert_score( (bigscore:new(300) * 300 * 300), "27000000" )
assert_score( (bigscore:new(300) * 300 * 300 * 300), "naneinf" )
assert_score( (bigscore:new(300) + naneinf:new(300)), "naneinf" )

-- deck sprite stuff

deck_sprite_index = 47
deck_sprite_pos_x = 112
deck_sprite_pos_y = 100
btn_deck=button_obj:new( {
	pos_x=112, pos_y=100,
	height=15,width=8,
	sprite_index=47,
})

-- buttons
btn_play_hand=button_obj:new( {
	pos_x=32, pos_y=110,
	sprite_index=64
} )
btn_discard_hand=button_obj:new( {
	pos_x=80, pos_y=110,
	sprite_index=66
} )
btn_buy_sprite_index = 74
btn_use_sprite_index = 75 
btn_sell_sprite_index = 76 

btn_go_next=button_obj:new( {
	pos_x=20, pos_y=50,
	sprite_index=70
} )
btn_reroll=button_obj:new( {
	pos_x=20, pos_y=70,
	sprite_index=72
} )

btn_full_deck=textbutton_obj:new( {
	pos_x=12, pos_y=100,
	text="full deck", color=12
} )
btn_remaining_deck=textbutton_obj:new( {
	pos_x=62, pos_y=100,
	text="remaining deck", color=12
} )
btn_exit=textbutton_obj:new( {
	pos_x=52, pos_y=115,
	text="exit", color=8
} )

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
sfx_add_chips=11
sfx_add_mult=12
sfx_multiply_mult=13
sfx_add_money=14

-- Game State
hand = {}
selected_cards = {}
shop_options = {}
scored_cards = {}
spade_cards = {} 
diamond_cards = {} 
heart_cards = {} 
club_cards = {}
joker_limit = 5
tarot_limit = 2
reroll_price = 5
hand_size = 8
score = bigscore:new(0)
chips = bigscore:new(0)
mult = bigscore:new(0)
hands = 4
discards = 4
money = 4
round = 1
goal_score = bigscore:new(300)
in_shop = false
is_viewing_deck = false
money_earned_per_round = 3

-- clear a table while preserving
-- object references to it
function clear(table)
	for i=#table,1,-1 do
		deli(table,i)
	end
end

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
	base_deck = create_base_deck()
	shuffled_deck = shuffle_deck(base_deck)
	deal_hand(shuffled_deck, hand_size)
	sfx(sfx_load_game)
end

-- only run if debugmouse=true
-- modify cards when scrolled
function scroll_cards(ms)
	for c in all(hand) do
		if c:moused() then
			c:add_rank(ms)
			return
		end
	end
end

btn_frames=0

function _update()
	mx = stat(32)
	my = stat(33)
 -- check score_hand animation
	if costatus(animation)!='dead' then
		coresume(animation)
		return
	end

 if debugmouse then
   local ms=stat(36)
   if ms!=0 then
   	scroll_cards(ms)
   end
 end
 	
    --register inputs
    -- Check mouse buttons
	-- btn(5) left click, btn(4) right click
	
	-- detect mouse-down event
	if btn(5) then
		if btn_frames==0 then 
			mouse_down()
		elseif picked_up_item then
			-- detect drag action
			picked_up_item:detect_moved()
		end
		btn_frames+=1
	elseif btn_frames>0 then
		mouse_up()
		btn_frames=0
	end

	-- simpler handlers
	if btnp(5) and not in_shop then 
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

	if btn(4) then	
		deselect_all_selected_cards()
	end

end

-- handle mouse-down event
function mouse_down()
	hand_collision_down()
end

-- handle mouse-up event
-- process clicks and drags
function mouse_up()
	if(not picked_up_item) return
	picked_up_item:drop()
	picked_up_item=nil
end

function _draw()
    -- draw stuff
    cls()
    	draw_background()
	-- print(stat(0),0,0,7)
	-- conditional draw
	if in_shop and not is_viewing_deck then
		draw_score()
		draw_shop()
		if costatus(animation)=='dead' then
			draw_go_next_and_reroll_button()
		end
		draw_shop_options()
		draw_deck()
		-- always draw
		draw_hands_and_discards()
		draw_money()
		draw_round_and_score()
		draw_joker_cards()
		draw_tarot_cards()
	elseif not in_shop and not is_viewing_deck then
		draw_hand()
		if costatus(animation)=='dead' then
			draw_play_discard_buttons()
		end
		draw_chips_and_mult()
		draw_score()
		draw_hand_type(hand_type_text)
		draw_deck()
		-- always draw
		draw_hands_and_discards()
		draw_money()
		draw_round_and_score()
		draw_joker_cards()
		draw_tarot_cards()
	elseif is_viewing_deck then
		draw_view_of_deck()
		btn_full_deck:draw()
		if not in_shop then
			btn_remaining_deck:draw()
		end
		btn_exit:draw()
	end
    draw_mouse(mx, my)
    draw_tooltips()
	draw_error_message()
	draw_sparkles()
end

function debug_message(txt)
	error_message = "\f7\#0" .. txt
	pause(15)
	error_message = ""
end

-- run as a coroutine so
-- yield commands can be used
function score_hand()
	pause(5) -- wait for sfx
 -- card are processed left-to-right
	sort_by_x(scored_cards)
	-- Score cards 
	for card in all(scored_cards) do
		add_chips( card.chips + card.effect_chips, card )
		add_mult( card.mult, card )
		for joker in all(joker_cards) do
			joker:card_effect(card)
		end
	end
	score_held_cards()
	score_jokers()
	score += (chips * mult)
	finish_scoring_hand()
	-- Reset
	chips = bigscore:new(0)
	mult = bigscore:new(0)
	hand_type_text = ""
end

function score_jokers()
	for joker in all(joker_cards) do
		joker:effect()
	end
end

-- after scoring played cards,
-- do effects for cards held in
-- hand (steel card, etc)
function score_held_cards()
	for card in all(hand) do
		if(not card.selected) card:when_held_in_hand()
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
	local hand_type = check_hand_type()
	if hand_type ~= "none" then
		hand_type_text = hand_type
		chips = bigscore:new(0)
		mult = bigscore:new(0)
		chips = chips + hand_types[hand_type].base_chips
		mult = mult + hand_types[hand_type].base_mult
	end
end

function deselect_all_selected_cards()
	for card in all(selected_cards) do
		select_hand(card)
		del(selected_cards, card)
		chips = bigscore:new(0)
		mult = bigscore:new(0)
		hand_type_text = ""
	end
end

function check_hand_type()
	scored_cards = {}
	if #selected_cards==0 then
		hand_type_text = ""
		return "none"
	end
	local flush=false
 if #selected_cards>=4 then
		flush=contains_flush(selected_cards)
	end
	local cf = card_frequencies()
	if flush then
		add_all_cards_to_score(selected_cards)
		if count(cf,5)>0 then
			return "flush five"
		elseif count(cf,3)>0 and count(cf,2)>0 then
			return "flush house"
		elseif contains_straight(cf) then
		 if contains_royal(cards) then
				return "royal flush"	
			else
				return "straight flush"
			end
		end
		return "flush"
	end
	--non-flush decision tree
	if count(cf,5)>0 then
		add_all_cards_to_score(selected_cards)
		return "five of a kind"
	elseif count(cf,4)>0 then
		score_cards_of_count(cf,4)
		return "four of a kind"
	elseif count(cf,3)>0 then
		score_cards_of_count(cf,3)
		if count(cf,2)>0 then
			score_cards_of_count(cf,2)
			return "full house"
		end
		return "three of a kind"
	elseif contains_straight(cf) then
		add_all_cards_to_score(selected_cards)
		return "straight"
	elseif count(cf,2)>0 then
		score_cards_of_count(cf,2)
		if count(cf,2)>1 then
			return "two pair"
		end
		return "pair"	
	end
	-- high card is all that's left
	add(scored_cards,get_highest_selected())
	return "high card"
end

function get_highest_selected()
	local min_order=99
	result=nil
	for card in all(selected_cards) do
		if card.order < min_order then
			result=card
			min_order=card.order
		end
	end
	return result
end

-- score sets of matching cards
function	score_cards_of_count(cf,qty)
	for i, q in pairs(cf) do
		if(q==qty) score_cards_of_order(i)
	end
end

-- score cards matched by order
-- as a proxy for rank, just
-- like card_frequencies()
function score_cards_of_order(o)
	for card in all(selected_cards) do
		if(card.order==o) add(scored_cards,card)
	end
end

function update_round_and_score() 
	round = round + 1
	goal_score = goal_score * 1.5
end

function win_state()
	for card in all(hand) do
		card:when_held_at_end()
		pause(1)
	end
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
	clear(tarot_cards)
	clear(joker_cards)
	round = 1
	goal_score = bigscore:new(300)
	card_selected_count = 0
	scored_cards = {}
	hands = 4
	discards = 4
	score = bigscore:new(0)
	reroll_price = 5
	shuffled_deck = shuffle_deck(base_deck)
	reset_card_params()
	selected_cards = {}
	scored_cards = {}
	shop_options = {}
	hand = {}
	hand_types = hand_types_copy
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
		add_money(5,nil)
	elseif money >= 5 then
		local interest = flr(money / 5)		
		add_money(interest,nil)
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

	-- Set the sorting order, also
	-- used as proxy for rank in 
	-- array returned by 
	-- card_frequencies()
	for i, card in pairs(ranks) do
		card.order = i
	end

	-- Create deck
	for x=1,#ranks do
		for y=1,#suits do
			card_info = card_obj:new({
				rank = ranks[x].rank,
				suit = suits[y],
				sprite_index = ranks[x].sprite_index,
				chips = ranks[x].base_chips,
				order = ranks[x].order,
			})
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
		card:reset()
	end
end

function build_sprite_index_lookup_table()
	-- Create deck
	for x=1,#ranks do
		ranks[x].sprite_index = x-1 
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
	--add(shop_options, get_special_card_by_name("raised fist", "Jokers"))
	--add(shop_options, get_special_card_by_name("death", "Tarots"))
end

function create_view_of_deck(table)
	heart_cards = {}
	diamond_cards = {}
	club_cards = {}
	spade_cards = {}

	for card in all(table) do
		if card.suit == "h" then
			add(heart_cards, card)
		elseif card.suit == "d" then
			add(diamond_cards, card)
		elseif card.suit == "c" then
			add(club_cards, card)
		elseif card.suit == "s" then
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

function distribute_hand()
	local x = 15	
	local y = 90 
		for card in all(hand) do
			if card.selected then
				card:place(x,y-10,5)
			else
				card:place(x,y,5)
			end
			x += card.width + draw_hand_gap
		end
end

function draw_hand()	
	if init_draw then
		distribute_hand()
		init_draw = false
	end
	for i=1,#hand do
		hand[i]:draw()
	end
end

function draw_mouse(x, y)
	palt(0x8000)
	if picked_up_item then
		picked_up_item:draw_at_mouse()
	end
	spr(192, x, y)
end

function draw_tooltips(x,y)
	if picked_up_item  then
		return -- none of these other
       		-- cards are targets.
	end
	for joker in all(joker_cards) do
		if joker:moused() then
			joker:describe() return
		end
	end
	for tarot in all(tarot_cards) do
		if mouse_sprite_collision(tarot.pos_x - card_width, tarot.pos_y, card_width*2, card_height*2) then
			tarot:describe() return
		end
	end
	if in_shop then
		for special_card in all(shop_options) do
			if mouse_sprite_collision(special_card.pos_x, special_card.pos_y, card_width, card_height*2) then
				special_card:describe() return
			end
		end
	end
end

function select_hand(card)
	if card.selected == false and card_selected_count < max_selected then 
		card.selected = true
		card_selected_count = card_selected_count + 1
		card:place(card.pos_x,card.pos_y-10,5)
	elseif card.selected == true then	
		card.selected = false
		card_selected_count = card_selected_count - 1
		card:place(card.pos_x,card.pos_y+10,5)
		if card_selected_count == 4 then error_message = "" end
	else
		sfx(sfx_error_message)
		error_message = "You can only select 5 \ncards at a time"
	end
end

function draw_play_discard_buttons()
	btn_play_hand:draw()
	btn_discard_hand:draw()
end

function draw_chips_and_mult()
	print("\f7" .. chips:str() .. "\#3 X \#8" .. mult:str(), 2, 70, 7)
	-- redraw to get good blue border
	print("\#c\f7" .. chips:str(), 2, 70, 7)
end

function draw_score()
	if in_shop == false then
		print("score:" .. score:str(), 2, 57, 7)
	else
		print("Scored Last:" .. score:str(), 30, 120, 7)
	end
end

function draw_hand_type()
	print(hand_type_text, 45, 70, 7)	
end

function draw_deck()
	rectfill(btn_deck.pos_x-1,btn_deck.pos_y-1,btn_deck.pos_x+6,btn_deck.pos_y+13,0)
	btn_deck:draw()
	print(#shuffled_deck .. "/" .. #base_deck, btn_deck.pos_x-9, btn_deck.pos_y + 20, 7)
end

function draw_hands_and_discards()
	print("h:" .. hands, 2, 102, 7)
	print("d:" .. discards, 2, 111, 7)
end

function draw_money()
	print("M:$" .. money, 2, 120, 7)
end

function draw_round_and_score()
	if in_shop == false then
		print("round:" .. round, 2, 39, 7)
		print("goal:" .. goal_score:str(), 2, 48, 7)
	else
		print("round:" .. round, 30, 102, 7)
		print("next goal:" .. goal_score:str(), 30, 111, 7)
	end
end

function draw_shop()
	rectfill(10, 35, 118, 90, 5) -- draw black background
end

function draw_go_next_and_reroll_button()
	palt()
	btn_go_next:draw()
	btn_reroll:draw()
	print("$"..reroll_price, 
		btn_reroll.pos_x + flr(card_width / 2), 
		btn_reroll.pos_y + btn_reroll.height, 7)
end

function draw_shop_options()
	local x = 60	
	for special_card in all(shop_options) do
		special_card:place(x,60)
		special_card:draw()
		x += card_width + draw_special_cards_gap
	end
end

function draw_joker_cards()
	local x = 15	
	local y = 4 
	for joker in all(joker_cards) do
		joker:place(x,y)
		joker:draw()
		x += card_width + draw_hand_gap + 5
	end
	print(#joker_cards.. "/" .. joker_limit, x, y, 7)
end

function draw_tarot_cards()
	local x = 82	
	local y = 20
	for tarot in all(tarot_cards) do
		tarot:place(x,y)
		tarot:draw()
		x += card_width + draw_hand_gap + 5 
	end
	print(#tarot_cards.. "/" .. tarot_limit, x, y, 7)
end

function draw_error_message()
	print(error_message, 30, 35, 8)
end

function draw_each_card_in_table(table, start_x, start_y, gap)
	local original_start_x = start_x
	for card in all(table) do
		if start_x > screen_width - card_width then
			start_y += card.height				
			start_x	= original_start_x
		end
		card:draw_at(start_x, start_y)
		card:place(start_x, start_y)
		start_x += card.width + gap 
		
	end
end

function draw_view_of_deck()
	local view_deck_card_gap_x = 1
	local view_deck_card_gap_y = 20
	local draw_start_pos_x = 5 
	local draw_start_pos_y = 10
	draw_each_card_in_table(heart_cards, draw_start_pos_x, draw_start_pos_y, view_deck_card_gap_x)

	draw_start_pos_y = draw_start_pos_y + view_deck_card_gap_y 
	draw_each_card_in_table(club_cards, draw_start_pos_x, draw_start_pos_y, view_deck_card_gap_x)

	draw_start_pos_y = draw_start_pos_y + view_deck_card_gap_y 
	draw_each_card_in_table(diamond_cards, draw_start_pos_x, draw_start_pos_y, view_deck_card_gap_x)

	draw_start_pos_y = draw_start_pos_y + view_deck_card_gap_y 
	draw_each_card_in_table(spade_cards, draw_start_pos_x, draw_start_pos_y, view_deck_card_gap_x)
end

-- Inputs

-- called when mouse-down to
-- check if card picked up
function hand_collision_down()
	for card in all(hand) do
		if card:moused() then
				card:pickup()
				card.drop_at=hand_collision_up
				break
		end
	end
end

-- drop a dragged card or click
function hand_collision_up(self,px,py)
	if(self.picked_up.moved) then
		if py < 50 or my > 102 then
			return
		end
		self.pos_x = px
		self.pos_y = py
		sort_by_x(hand)
		distribute_hand()
	else -- click, not drop
		sfx(sfx_card_select)
		select_hand(self)
		update_selected_cards()
	end
end

function mouse_sprite_collision(sx, sy, sw, sh)
    return mx >= sx and mx < sx + sw and
           my >= sy and my < sy + sh
end

function play_button_clicked()
	if btn_play_hand:moused() and #selected_cards > 0 and hands > 0 then
		sfx(sfx_play_btn_clicked)
		hands = hands - 1
		animation=cocreate(score_hand)
end

function finish_scoring_hand()
		if score:greater_or_equal(goal_score) then
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
	if btn_discard_hand:moused() and #selected_cards > 0 and discards > 0 then
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
	if btn_go_next:moused()	and in_shop then
		sfx(sfx_card_select)
		in_shop = false			
		shop_options = {}
		error_message = ""
		reroll_price = 5
		score = bigscore:new(0)
	end
end

function reroll_button_clicked()
	if btn_reroll:moused() and in_shop == true and money >= reroll_price then
		sfx(sfx_buy_btn_clicked)
		money = money - reroll_price
		shop_options = {}
		add_cards_to_shop()
		reroll_price = reroll_price + 1
	elseif btn_reroll:moused() and in_shop == true and money < reroll_price then
		sfx(sfx_error_message)
		error_message = "You don't have enough\n money to reroll.\n Get your money up."
	end
end

function buy_button_clicked()
	for special_card in all(shop_options) do
		if mouse_sprite_collision(special_card.pos_x, special_card.pos_y + card_height, card_width, card_height)
and in_shop == true and money >= special_card.price then
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
				money -= special_card.price
				sfx(sfx_buy_btn_clicked)
				if special_card.name == "the hermit" then
					animation=cocreate(function()
						pause(9) -- wait for sfx
						special_card:effect()	
						pause(1) -- one more frame
						del(shop_options, special_card)
					end)
				
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
				money -= special_card.price
				sfx(sfx_buy_btn_clicked_planet)
				special_card:effect()
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
			update_selected_cards()
		end
	end
end

function view_deck_button_clicked()
	if btn_deck:moused() then
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
	if btn_full_deck:moused() then
		sfx(sfx_card_select)
		create_view_of_deck(base_deck)
	end
end

function remaining_deck_button_clicked()
	if btn_remaining_deck:moused() then
		sfx(sfx_card_select)
		create_view_of_deck(shuffled_deck)
	end
end

function exit_view_deck_button_clicked()
	if btn_exit:moused() then
		sfx(sfx_card_select)
		is_viewing_deck = false 
	end
end

-- hand detection

-- collect card frequencies to
-- detect matches and runs.
-- indexed by card.order as a
-- numeric proxy for rank.
function card_frequencies()
	local histogram={0,0,0,0,0,0,0,0,0,0,0,0,0}
	for card in all(selected_cards) do
		histogram[card.order] += 1
	end
	return histogram
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

function contains_flush(cards)
	local run_goal=5
	if(has_joker("four fingers"))run_goal=4
	if(#cards<run_goal) return
	local first=cards[1]
	local ct=0
	for card in all(cards) do 
		if(card:matches_suit(first)) ct+=1
		if(ct>=run_goal)return true
	end
	return false
end

function contains_royal(cards)
	-- only called if straight is
	-- already detected, so just
	-- return false if any 
	-- commoners present
 local royals={'a','k','q','j','10'}
	for c in all(cards) do
		if(not contains(royals,c.rank)) return false
	end
	return true
end

function contains_straight(cf)
	-- todo: implement shortcut joker
	local run_goal=5
	if(has_joker("four fingers"))run_goal=4
	if #selected_cards<run_goal then
		return false
	end
	local run_length=0
	-- detect run
	for f in all(cf) do
		if f>0 then
			run_length += 1
			if run_length >= run_goal then
				return true
			end
		else
			run_length=0
		end
	end
	-- special case for a,2,3,4,5
	if run_length == run_goal-1
		and cf[1] > 0 then
		return true
	end
	-- insufficient run
	return false
end

function add_all_cards_to_score(cards)
	for card in all(cards) do
		add(scored_cards, card)
	end
end

-- when cards are moved by mouse
function sort_by_x(cards)
	sort_by("pos_x",cards)
end

-- when cards are drawn
function sort_by_rank_decreasing(cards)
	sort_by("order",cards)
end

function sort_by(property,cards)
	-- insertion sort
	for i=2,#cards do
		current_order = cards[i][property]
		current = cards[i]
		j = i - 1
		while (j >= 1 and current_order < cards[j][property]) do
			cards[j + 1] = cards[j]
			j = j - 1
		end
		cards[j + 1] = current
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


-- TEST
function test_print_table(table)
	local text = ""
	for card in all(table) do
		text = text .. " " .. card.rank .. card.suit
	end
	printh(text)
end

__gfx__
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77777ccd77777ee877777766
bbb88bbbb88bb88bbb8888bbbbbbb88bb8bb88bbbb8888bbbb8888bbb888888bbb8888bbb888888bbbbb88bbb888888bbb8888bb7777777c7777777e77777776
bb8888bbb88b88bbb88bb88bbbbbb88bb8b8bb8bb88bb88bb88bb88bbbbbb88bb88bbbbbb88bbbbbbbb888bbbbbb88bbb88bb88b7777777c7777777e77777777
b88bb88bb8888bbbb88bb88bbbbbb88bb8b8bb8bbb88888bbb8888bbbbbb88bbb88888bbb88888bbbb8888bbbbb88bbbbbbb88bb7777777c7777777e77777777
b88bb88bb8888bbbb88bb88bbbbbb88bb8b8bb8bbbbbb88bb88bb88bbbb88bbbb88bb88bbbbbb88bb88b88bbbbbb88bbbbb88bbb7777777c7777777e77777777
b888888bb88b88bbb88b88bbb88bb88bb8b8bb8bbbbb88bbb88bb88bbb88bbbbb88bb88bb88bb88bb888888bb88bb88bbb88bbbb777777777777777777777777
b88bb88bb88bb88bbb88b88bbb8888bbb8bb88bbbb888bbbbb8888bbbb88bbbbbb8888bbbb8888bbbbbb88bbbb8888bbb888888b777777777777777777777777
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb777777777777777777777777
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000777777777777777777777777
bbbb8bbbbbb888bbbbb8b8bbbbbb8bbb000000000000000000000000000000000000000000000000000000000000000000000000777777777777777777777777
bbb888bbbbb888bbbb88888bbbb888bb000000000000000000000000000000000000000000000000000000000000000000000000c7777777e777777777777777
bb88888bbb88b88bbb88888bbb88888b000000000000000000000000000000000000000000000000000000000000000000000000c7777777e777777777777777
bb88888bbb88b88bbbb888bbbbb888bb000000000000000000000000000000000000000000000000000000000000000000000000c7777777e777777777777777
bbbb8bbbbbbb8bbbbbbb8bbbbbbb8bbb000000000000000000000000000000000000000000000000000000000000000000000000c7777777e777777767777777
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000001cc777778ee7777766777777
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbb
bb1bbbbbb2b2bbbb88888bbbb060bbbb000000000000000000000000000000000000000000000000000000000000000077777766aaaaa777666667778c8c8c8c
b1c1bbbb28282bbb87878bbbb0660bbb000000000000000000000000000000000000000000000000000000000000000077777776aaaaaaa766666667c8c8c8c8
1ccc1bbbb282bbbb88788bbb0660bbbb000000000000000000000000000000000000000000000000000000000000000077777777aaaaaaa7666666678c8c8c8c
b1c1bbbb28282bbb87878bbb06660bbb000000000000000000000000000000000000000000000000000000000000000077777777aaaaaaaa66666666c8c8c8c8
bb1bbbbbb2b2bbbb88888bbbb0660bbb000000000000000000000000000000000000000000000000000000000000000077777777aaaaaaaa666666668c8c8c8c
bbbbbbbbbbbbbbbbbbbbbbbb0660bbbb000000000000000000000000000000000000000000000000000000000000000077777777aaaaaaaa66666666c8c8c8c8
bbbbbbbbbbbbbbbbbbbbbbbbb060bbbb000000000000000000000000000000000000000000000000000000000000000077777777aaaaaaaa666666668c8c8c8c
bbbbbbbbbbbbbbbbbbbbbbbbbb0bbbbb000000000000000000000000000000000000000000000000000000000000000077777777aaaaaaaa66666666c8c8c8c8
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777777aaaaaaaa666666668c8c8c8c
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077760057aaaaaaaa66666666c8c8c8c8
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077600506aaaaaaaa666666668c8c8c8c
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077650056aaaaaaaa66666666c8c8c8c8
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000776050069aaaaaaa566666668c8c8c8c
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000677500679aaaaaaa56666666c8c8c8c8
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066777777999aaaaa555666668c8c8c8c
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
cccccccccccccccceeeeeeeeeeeeeeee00000000000000008888888888888888bbbbbbbbbbbbbbbb8aaa8a8a8a8a8888bbbabbba000000000000000000000000
cccccccccccccccce777e777e777eeee00000000000000008887778877777788bb77777bb77777bb888a8a8a888a8aaabaaabaaa000000000000000000000000
c777c7cc777c7c7ce7e7ee7ee7eeeeee00000000000000008878888878888788bb7bbb7bb7bbbbbb8a8a8a8aaaaa8aaabbbabbaa000000000000000000000000
c7c7c7cc7c7c7c7ce7e7ee7ee777eeee00000000000000008788888878888788bb77777bb777bbbb888a888a888a88aaaababaaa000000000000000000000000
c777c7cc777c7c7ce7e7ee7eeee7e77e00000000000000008788778878888788bb7b7bbbb7bbbbbbaaaaaaaa8aaa8aaabbbabbba000000000000000000000000
c7ccc7cc7c7cc7cce7e7ee7eeee7eeee00000000000000008788878878888788bb7bb7bbb7bbbbbbaa8a8aaa888a8aaaaaaaaaaa000000000000000000000000
c7ccc77c7c7cc7cce777e777e777eeee00000000000000008777778877777788bb7bbb7bb77777bbaaa8aaaaaa8a8aaabaaabaaa000000000000000000000000
cccccccccccccccceeeeeeeeeeeeeeee00000000000000008888888888888888bbbbbbbbbbbbbbbbaaa8aaaa888a8888bbbabbba000000000000000000000000
cccccccccccccccceeeeeeeeeeeeeeee00000000000000008888888888888888bbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000
cccccccccccccccceeeeeeeeeeeeeeee00000000000000008777877878787778b7777b777b7bb7bb000000000000000000000000000000000000000000000000
c7c7c777c777c777e77e777e777e777e00000000000000008787878878788788b7bb7b7b7b7bb7bb000000000000000000000000000000000000000000000000
c7c7c7c7c7c7c7c7e7ee7e7e7e7e7e7e00000000000000008787877878788788b7777b7b7b7bb7bb000000000000000000000000000000000000000000000000
c777c777c7c7c7c7e7ee777e777e7e7e00000000000000008787878887888788b7b7bb7b7b7bb7bb000000000000000000000000000000000000000000000000
c7c7c7c7c7c7c7c7e7ee7e7e77ee7e7e00000000000000008787878878788788b7bb7b7b7b7bb7bb000000000000000000000000000000000000000000000000
c7c7c7c7c7c7c777e77e7e7e7e7e777e00000000000000008787877878788788b7bb7b777b77b77b000000000000000000000000000000000000000000000000
cccccccccccccccceeeeeeeeeeeeeeee00000000000000008888888888888888bbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000
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
7777777777787777777777777788877777878777778787777787877700000000777c7777777c777777ccc777788877777c777777771077775555555544444444
778787777788877775555577778787777778777777787777777877770000000077ccc77777ccc77777c7c77778777777c7c77777711107775585585544474444
7777777777787777595959577787877777878777778787777787877700000000777c7777777c777777c7c77778877887c7c777771111107755855855444c0444
7778777778888877595959577777877778777888778888777788887700000000c777ccccccc7cccc7777c777787778777c7ccccc7111097755555555444cc544
7877787778777877759595577778877778777877777778777777787700000000c777c77cc7c7c77c777cc7777888788777777c777710797755588555448c8544
7788877778888877775999577778777778777888777787777777887700000000ccccc77cccc7c77c777c77777777778777777c777777797755888855488d8584
7777777778777877777599577777777778787778777877777777787700000000c77cc77c77c7c77c777777777777788777777c777777797755855855488d8584
7777777778888877777599577778777778777888778888877788887700000000cccccccc77c7cccc777c77777777777777777777777777775555555566666666
ccccccccccccccccc777c777777ccccccccccccc888888cc7777777cc777c777cccccccc777ccccc0000000000000000000000000000000000000000ffffffff
ccccccccccccccccc7c7c7c77c7ccccccccccccc8c88c8cc7c7c7c7cc7c7c7c7cccccccc7c7ccccc0000000000000000000000000000000000000000f55f55ff
ccc777ccc777c777c777c77777777ccccccccccc888888cc7777777cc777c777cccccccc777ccccc0000000000000000000000000000000000000000f5ff55ff
ccc7c7ccc7c7c7c7cccccccccc7c7ccccccc7777888888cccccccccccccccccccccc888877cc88880000000000000000000000000000000000000000f5ff55ff
ccc7c7ccc7c7c7c7c777c777cc77777cccc777778c88c8cccc77777cc777c777ccc888887c7888880000000000000000000000000000000000000000f55ff5ff
ccc777ccc777c777c7c7c7c7cccc7c7ccc77777788888888cc7c7c7cc7c7c7c7cc888888cc8888880000000000000000000000000000000000000000f55ff5ff
ccccccccccccccccc7c7c7c7cccc777cc7777777ccccc8c8cc7c7c7cc777c777c8888888c88888880000000000000000000000000000000000000000f55f55ff
ccccccccccccccccc777c777cccccccc77777777ccccc888cc77777ccccccccc88888888888888880000000000000000000000000000000000000000ffffffff
f777f7778888888f9999999fcccccccfdddddddfffffffffffffffffafafaaaf777f777fffffffffffffffff0000000000000000000000000000000000000000
f7f7f7f78f8f8f8f9f9f9f9fcfcfcfcfdfdfdfdfff8888ffffccccfffaffffaf7f7f7f7ffaaaa77ff666677f0000000000000000000000000000000000000000
f7f7f7f78888888f9999999fcccccccfdddddddfff8ff8ffffcffcffafafaaff777f777ffaaaaa7ff666667f0000000000000000000000000000000000000000
f777f777ffffffffffffffffffffffffffffffffff8888ffffccccffffffaffffffffffffaaaaaaff666666f0000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaaaaf55555fffaaaaaaff666666f0000000000000000000000000000000000000000
f777f777ffffffffffffffffffffffffffffffffff8888ffffccccffaaaaafffffdddffff9aaaaaff566666f0000000000000000000000000000000000000000
f7f7f7f7ffffffffffffffffffffffffffffffffff8ff8ffffcffcffafafafffffdddffff99aaaaff556666f0000000000000000000000000000000000000000
f777f777ffffffffffffffffffffffffffffffffff8888ffffccccffafafafffffdddfffffffffffffffffff0000000000000000000000000000000000000000
00000000788788777779777777ccc777777d7777777777777777777f777777770000000000000000000000000000000000000000000000000000000000000000
0000000088a8a88777c9c777773c377777cdc777778787777067706f77f7f7770000000000000000000000000000000000000000000000000000000000000000
000000008888888779999977ccccccc77ddddd77778787777067706f77f7f7f70000000000000000000000000000000000000000000000000000000000000000
000000008a888a879c999c97c3c7c3c7d8ddd8d7778887777067706f77f7f7f70000000000000000000000000000000000000000000000000000000000000000
0000000078aaa87779ccc977cc333cc77d888d77788888777677767f77fffff70000000000000000000000000000000000000000000000000000000000000000
000000007788877777999777777c7777777d7777788888777770777ff7fffff70000000000000000000000000000000000000000000000000000000000000000
00000000777877777779777777ccc77777ddd777788888777776777f7ffffff70000000000000000000000000000000000000000000000000000000000000000
000000007777777777777777777777777777777777888777ffffffff777fff770000000000000000000000000000000000000000000000000000000000000000
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
000100001c0503055020550100501c5502555015550100501d5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001055010550235502355023530235100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500002135021310393503931000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000086700a6300d6601063012650156101764017610146001560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
