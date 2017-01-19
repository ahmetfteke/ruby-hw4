require_relative 'AntFarm'
require_relative 'Room'

class Anthill
	attr_accessor :anthill_name, :anthill_id, :food, :builder_rooms, :warrior_rooms, :forager_rooms, :ant_kills, :colony_kills, :warrior_c, :builder_c, :forager_c, :x, :y, :strategy
	

	def initialize()
		#created rooms for each ant types.
		@builder_rooms = Array.new()
		@warrior_rooms = Array.new()
		@forager_rooms = Array.new() 

		# resource counter
		@food = 0
		@ant_kills = 0 
		@colony_kills = 0

		#holds references for each ant types.
		@warrior_c = 0
		@builder_c = 0
		@forager_c = 0

		# we need inital builder to atleast have one builder 
		@builder_rooms << Room.new()

	end

	def do_action()
		decision()
	end

	def decision()
		rand_choice= rand() 
		#logic goes here.
	end

	def create_warrior()
		@warrior_rooms.each do |room|
			if(room.idle and @food > 0)
				room.idle = false
				@food -= 1
				@warrior_c += 1
				m = Meadow.instance
				m.cells[m.x][m.y].ants <<  AntFarm.create_ant(:warrior, @anthill_id, m.x, m.y)			
			end
		end
	end

	def create_forager()
		@forager_rooms.each do |room|
			if(room.idle and @food > 0)
				room.idle = false
				@food -= 1
				@forager_c += 1
				m = Meadow.instance
				m.cells[m.x][m.y].ants <<  AntFarm.create_ant(:forager, @anthill_id, m.x, m.y)
			end 
		end
	end

	def create_builder()
		@builder_rooms.each do |room|
			if(room.idle and @food > 0)
				room.idle = false
				@food -= 1
				@builder_c += 1
				AntFarm.create_ant(:builder, @anthill_id, 0, 0)
			end
		end
	end	

	def make_room_warrior()
		if @builder_c > 0
			@warrior_rooms << Room.new()
			@food -= 1
			@builder_c -= 1
		end

	end

	def make_room_builder()
		if @builder_c > 0
			@builder_rooms << Room.new()
			@food -= 1
			@builder_c -= 1
		end
	end

	def make_room_forager()
		if @builder_c > 0
			@forager_rooms << Room.new()
			@food -= 1
			@builder_c -= 1
		end
	end

	def set_war_room_idle()
		@warrior_rooms.each do | room|
			room.idle = true
		end
	end

	def set_forager_room_idle()
		@forager_rooms.each do | room|
			room.idle = true
			
		end
	end

	def set_builder_room_idle()
		@builder_rooms.each do |room|
			room.idle = false
		end
		(@builder_rooms.size - @builder_c).times do  |i|
			@builder_rooms[i].idle = true
		end
	end	

	def set_rooms_idle()
		set_war_room_idle
		set_forager_room_idle
		set_builder_room_idle
	end
end
