class Cell
	attr_accessor :hill, :food, :ants
	def initialize
		@hill = nil
		@food = 0
		@ants = Array.new
	end
end