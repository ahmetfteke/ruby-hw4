require_relative 'AntFarm.rb'
require_relative 'Anthill.rb'
class Queen
	def initialize(id, x, y)
		@queen = AntFarm.create_ant(:queen, id,x ,y)
		@anthill = Anthill.new
	end
	def set_anthill_id(id)
		@anthill.anthill_id = id
		self
	end
	def set_anthill_coordinate(x, y)
		@anthill.x = x
		@anthill.y = y
		self
	end
	def set_strategy(strategy)
		@anthill.strategy = strategy
		self
	end
	def set_anthill_name(anthill_name)
		@anthill.anthill_name = anthill_name
		self
	end
	def add_food
		@anthill.food += 5
		self
	end
	
	def anthill
		@anthill
	end
end