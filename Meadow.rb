require 'singleton'
require_relative 'Cell.rb'
require_relative 'AntFarm.rb'
require_relative 'Queen.rb'
include Enumerable

class Meadow
	attr_accessor :cells, :x, :y
	include Singleton

	@@x_size = 25
	@@y_size = 25

	@x = 0
	@y = 0

	def initialize
		@cells  =  Array.new(@@x_size) { Array.new(@@y_size) }
		@ant_farm = AntFarm.new
		@hill_hash = Hash.new
		@died_ids = Array.new
	end
	
	def meadow_setup
		set_cells
		add_anthills
		play

		# move_ant
		# forage_take_food
		# move_ant
		# forage_take_food
		# print_ants
		# puts("Movedan once *************************************************")

		# move_ant
		# #add_food
		#  print_ants
		#  puts("Movedan once *************************************************")
		# # move_ant
		# # puts("Movedan sonra *************************************************")
		# # print_ants
		# # puts("Movedan sonra *************************************************")
		# # move_ant
		# # print_ants
		
	end

	def set_cells
		# create sells
		(0..@@x_size-1).each do |x|
			(0..@@y_size-1).each do |y|
				@cells[x][y] = Cell.new
			end
		end
		
	end

	def add_food
		# add 10 foods
		(1..10).each{
			rx, ry = get_random_x_y
			# if there is a anthill, add food to anthill
			if @cells[rx][ry].hill != nil 
				@cells[rx][ry].hill.food += 1
				# puts "#{@cells[rx][ry].hill.anthill_name} Lucky strike!"
			else
				@cells[rx][ry].food += 1
			end
			 # puts "Food added coordinate. X: #{rx} Y: #{ry}"
		}
	end

	def add_anthills
		# add anthills
		puts "Releasing queen arts"
		(1..10).each do |i|
			rx, ry = get_random_x_y
			# if random x,y are already hill
			while @cells[rx][ry].hill != nil
				rx, ry = get_random_x_y
			end
			strategy = get_random_strategy
			@cells[rx][ry].hill = Queen.new(i, rx, ry).set_anthill_id(i).set_strategy(strategy).set_anthill_coordinate(rx, ry).set_anthill_name("Anthill Name: #{i}").add_food.anthill
			@hill_hash[i] = [rx, ry]
			puts "Anthill Name: #{i}"
			puts "Coordinate X: #{rx}, Y: #{ry}"
			@x = rx
			@y = ry
			@round_c = 0
		end
	end

	def get_random_x_y
		return rand(@@x_size), rand(@@y_size)
	end
	def get_random_strategy
		["agressive", "defensive", "balanced"].sample
	end
	def each(&block)
    	@cells.each(&block)
  	end

  	def move_ant()
  		@cells.each_with_index do |x,xi|
  			x.each_with_index do |y,yi|
  				y.ants.each do |ant|
  					if ant.can_move
		    			ant.can_move = false
		    			# puts "element [#{xi}, #{yi}] is #{ant.anthill_id}"
						visiblematrix= []
						if((@cells[xi-1].class != NilClass) and (xi-1 != -1))
							visiblematrix << [xi-1,yi]
						end
						if(@cells[xi][yi-1].class != NilClass and yi-1 != -1 )
							visiblematrix << [xi,yi-1]
						end
						if(@cells[xi+1].class != NilClass)
							visiblematrix << [xi+1,yi]
						end
						if(@cells[xi][yi+1].class != NilClass)
							visiblematrix << [xi,yi+1]
						end							
		    			ant.x, ant.y = visiblematrix.sample
		    		end
				end
	  		end
		end
		@cells.each_with_index do |x,xi|
  			x.each_with_index do |y,yi|
  				y.ants.length.times do |i|
  					ant = y.ants.shift
  					ant.can_move = true
  					@cells[ant.x][ant.y].ants << ant
  				end
  			end
  		end
  		
	end

	def do_action_anthills()

		cells.each do |x|
			x.each do |y|
				y.hill.do_action()
			end
		end
		
	end
	def play
		while true
			if @hill_hash.length > 1
				@hill_hash.each { |key, value|
					@x = value[0]
					@y = value[1]
					#puts @cells[@x][@y].hill.warrior_c.to_s
					#puts @cells[@x][@y].hill.forager_c.to_s
					if @round_c > 5 and @cells[@x][@y].hill.warrior_c == 0 and @cells[@x][@y].hill.forager_c == 0
						@hill_hash.delete(key)
						break
					end 
					if @round_c <= 5
						start_play
					else
						round_play
					end

				}
				add_food
				move_ant
				correct_ants
				# war_kill_each_other
				# war_kill_forager
				battle
				correct_ants
				print_ants
				forage_take_food
				correct_ants
				report
				correct_ants

			 	# gets
				
			elsif @hill_hash.length == 1
				key, value = @hill_hash.first 
				puts "Game ended. Winner anthill id: #{key}"
				break
			else
				puts "Game ended. Unfortunately no winner."
				break
			end
			@round_c += 1
		end
	end
	def battle
		@cells.each_with_index do |x,xi|
  			x.each_with_index do |y,yi|
				warrior_anthill_ids = Array.new
				warrior_c = 0
  				y.ants.each { |ant|  
  					if ant.ant_type == "warrior"
  						warrior_c += 1
  						warrior_anthill_ids << ant.anthill_id
  					end
  				}
  				# there is warrior and not only one 
  				if warrior_anthill_ids.size != 0 and warrior_c > 1
  					@winner_anthill_id = warrior_anthill_ids.sample
  					y.ants.each { |ant|  
  						# if this ant's nation id is not winner
	  					if ant.anthill_id != @winner_anthill_id
	  						puts "Ant number before war: "+ get_ant_counter
  							puts "Winner nation: #{@winner_anthill_id} Battle area x:#{xi} y:#{yi}"
	  						y.ants.delete(ant)
	  						puts "Ant number after war:  "+ get_ant_counter
	  					end
  					}
  				end
  				if  y.hill != nil and warrior_c > 0
  						@current_anthill_id = y.hill.anthill_id
  						if @current_anthill_id != @winner_anthill_id
	  						# % 20 percent chance
	  						chance = rand(100)
	  						if chance >= 80
	  							puts "**!**!*!*!*! Nation died #{@current_anthill_id}"
	  							value = @hill_hash[@winner_anthill_id]
  								@cells[value[0]][value[1]].hill.colony_kills += 1
	  							@cells.each_with_index do |x_2,xi_2|
									x_2.each_with_index do |y_2,yi_2|
										y_2.ants.each { |ant|
											if ant.anthill_id == @current_anthill_id
												puts "**!**!*!*!*! died x:#{xi_2}, y:#{yi_2}"
												y_2.ants.delete(ant)
					  							value = @hill_hash[@winner_anthill_id]
					  							@cells[value[0]][value[1]].hill.ant_kills += 1
						  						
											end
										}
									end
								end
								@hill_hash.delete(@current_anthill_id)
  								y.hill = nil
  								@died_ids << @current_anthill_id 
	  						end
	  						
  						end
  					end
  			end
  		end

	end
	def correct_ants
		@cells.each_with_index do |x,xi|
			x.each_with_index do |y,yi|
				y.ants.each { |ant|
					if @died_ids.include? ant.anthill_id 
						y.ants.delete(ant)
					end
				}
			end
		end
	end
	def start_play
		if @round_c == 0
			@cells[@x][@y].hill.create_builder
		elsif @round_c == 1
			@cells[@x][@y].hill.make_room_forager
			@cells[@x][@y].hill.set_rooms_idle
		elsif @round_c == 2
			@cells[@x][@y].hill.create_forager
			@cells[@x][@y].hill.set_rooms_idle
		elsif @round_c == 3
			@cells[@x][@y].hill.create_forager
			@cells[@x][@y].hill.set_rooms_idle
		elsif @round_c == 4
			@cells[@x][@y].hill.create_builder
		elsif @round_c == 5
			@cells[@x][@y].hill.make_room_warrior
			@cells[@x][@y].hill.set_rooms_idle
		end
		
	end
	def round_play
		i = rand(2)
		if i == 0
			@cells[@x][@y].hill.create_warrior
			@cells[@x][@y].hill.set_rooms_idle
		else
			@cells[@x][@y].hill.create_forager
			@cells[@x][@y].hill.set_rooms_idle
		end
		# @cells[@x][@y].hill.create_builder
		# @cells[@x][@y].hill.set_rooms_idle
		# @cells[@x][@y].hill.make_room_warrior
		# @cells[@x][@y].hill.set_rooms_idle
		# @cells[@x][@y].hill.create_warrior
		# @cells[@x][@y].hill.set_rooms_idle
		# @cells[@x][@y].hill.create_warrior
		# @cells[@x][@y].hill.set_rooms_idle
		# @cells[@x][@y].hill.set_rooms_idle
		# @cells[@x][@y].hill.create_warrior
		# round_routine
		# @cells[@x][@y].hill.set_rooms_idle
		# @cells[@x][@y].hill.create_warrior
		# round_routine
		# @cells[@x][@y].hill.set_rooms_idle
		# @cells[@x][@y].hill.create_forager
		# round_routine
		# @cells[@x][@y].hill.set_rooms_idle
		# @cells[@x][@y].hill.create_forager
		# round_routine
		# @cells[@x][@y].hill.set_rooms_idle
		# @cells[@x][@y].hill.create_forager
		# round_routine
		# @cells[@x][@y].hill.set_rooms_idle
	end
	def print_ants
		counter = 0
		@cells.each_with_index do |x,xi|
			x.each_with_index do |y,yi|
				y.ants.each { |e|
				counter = counter +1  
					puts"ID: #{e.anthill_id}  Type: #{e.ant_type},  X coordinates: #{xi}, Y cooardinates: #{yi}"
				}
			end
		end
		puts "-----------------"
	end

	def forage_take_food
  		@cells.each_with_index do |x,xi|
  			x.each_with_index do |y,yi|
  				if(@cells[xi][yi].food > 0)
  					y.ants.each do |ant|
  						if(ant.ant_type=="forager")
  							m, n = @hill_hash[ant.anthill_id]
  							@cells[xi][yi].food -= 1
							@cells[m][n].hill.food += 1
							puts "Food buldum ! #{ant.anthill_id} #{ant.ant_type},  X coordinates: #{xi}, Y cooardinates: #{yi}"
  						end
  					end
  				end
  			end
  		end
  	end


  	def check_war_different_hill
		@counter=0
	  	@cells.each_with_index do |x,xi|
	  		x.each_with_index do |y,yi|
	  			y.ants.each do |ant|
	  				if(ant.ant_type == "warrior")
	  					@counter= @counter +1
	  					if(@counter == 1)
	  						@first_anthill_id=ant.anthill_id
	  					end
	  					if(@first_anthill_id != ant.anthill_id)
	  						return true
	  					end
					end
				end
			end	
		end
		return false
	end
	def get_ant_counter
		c = 0
		@cells.each_with_index do |x,xi|
			x.each_with_index do |y,yi|
				y.ants.each { |e|
					c+=1
				}
			end
		end
		c.to_s
	end
	def war_kill_each_other()
		#puts"11111111111111111111"
		if(true)
			# => puts"2222222222222222222222"

			@cells.each_with_index do |x,xi|
	  			x.each_with_index do |y,yi|
	  				@warrior_holder= Array.new()

	  				y.ants.each_with_index do |ant,anti|
	  					puts"Anthill ID:#{ant.anthill_id} #{anti}"

	  					if(ant.ant_type == "warrior")
	  						@warrior_holder << ant
	  					end
	  				end
			
	  				if(@warrior_holder.length>0)
	  					# determining winner warrior.
	  					@winner_war= @warrior_holder.sample()
	  					#determninig winner anthill
	  					@winner_anthill_id= @winner_war.anthill_id
	  					#puts("33333333333333333333333333333333333333")

	  					y.ants.each_with_index do |ant,anti|
	  						puts"****************    Anthill ID:#{ant.anthill_id} #{anti}"
	  						if(ant.ant_type=="warrior" and ant.anthill_id != @winner_anthill_id)
	  							m, n = @hill_hash[@winner_anthill_id]
	  							k,l = @hill_hash[ant.anthill_id]
	  							#increasing ant kills of the winner warrior's hill.
  								@cells[m][n].hill.ant_kills += 1
  								@cells[k][l].hill.warrior_c -=1
	  							@cells[xi][yi].ants.delete(ant)
	  							puts("66666666666666666666666666666666")
	  							puts"#{@winner_anthill_id} Kesiyor #{ant}"
	  						end
	  					end	
	  				end
	  			end
	  		end
	  	end			
	end
 #  	def check_war_with_forager
	# 	@war_flag=false
	# 	@forager_flag=false

	#   	@cells.each_with_index do |x,xi|
	#   		x.each_with_index do |y,yi|
	#   			y.ants.each do |ant|
	#   				if(ant.ant_type == "warrior")
	#   					@war_flag= true
	#   				end
	#   				if(ant.ant_type== "forager")
	#   					@forager_flag=true
	#   				end
	#   				if(@war_flag and @forager_flag)
	#   						return true
	#   				end
					
	# 			end
	# 		end	
	# 	end
	# 	return false
	# end

	def war_kill_forager()
		if(true)
			@cells.each_with_index do |x,xi|
	  			x.each_with_index do |y,yi|
	  				@forager_holder= Array.new()

	  				y.ants.each do |ant|		
	  					if(ant.ant_type == "forager")
	  						@forager_holder << ant
	  					end
	  				end

	  				y.ants.each do |ant|
	  					if(ant.ant_type == "warrior")
	  						@war_anthill_id= ant.anthill_id
	  					end
	  				end
	  				if(@war_anthill_id.class != NilClass)
		  				y.ants.each do |ant|
		  					# puts ant.ant_type
		  					# puts ant.anthill_id
		  					# puts @war_anthill_id
		  					if(ant.ant_type=="forager" and ant.anthill_id != @war_anthill_id)
		  						m, n = @hill_hash[@war_anthill_id]
		  						k,l= @hill_hash[ant.anthill_id]
	  							@cells[m][n].hill.ant_kills += 1
	  							@cells[k][l].hill.forager_c-=1
		  						@cells[xi][yi].ants.delete(ant)	  						
		  					end
		  				end
		  			end
	  			end
	  		end
	  	end
	end

	def report 
		@hill_hash.each do |key,value|
			@m=value[0]
			@n=value[1]

			name=@cells[@m][@n].hill.anthill_name
			forager_ant = @cells[@m][@n].hill.forager_c
			builder_ant = @cells[@m][@n].hill.builder_c
			warrior_ant = @cells[@m][@n].hill.warrior_c

			colony_kills = @cells[@m][@n].hill.colony_kills
			ant_kills = @cells[@m][@n].hill.ant_kills

			puts"Anthill Name: #{name}"
			puts"Forager Ants: #{forager_ant}"
			puts "Builder Ants: #{builder_ant}"
			puts "Warrior Ants: #{warrior_ant}"
			puts"Ant Kills: #{ant_kills}"
			puts "Colony Kills: #{colony_kills}"
			puts" "

			puts"=================================="

		end
	end


end