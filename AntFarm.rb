require_relative 'Ant.rb'
class AntFarm
	def self.create_ant(type, id, x, y)
		# run time modification for ant
		ant = Ant.new
		case type
		when :queen
			ant.ant_type = "queen"
		when :forager
			ant.ant_type = "forager"
		when :builder
			ant.ant_type = "builder"
		when :warrior
			ant.ant_type = "warrior"
		end
		ant.anthill_id = id
		ant.can_move = true
		ant.x = x
		ant.y = y
		ant
	end
end