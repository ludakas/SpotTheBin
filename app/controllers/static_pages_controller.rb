class StaticPagesController < ApplicationController
	def index
		@games = Game.all
	end

	def how_to_play

	end

	def what_is_spot_the_bin

	end

	def send_data
		gname = params[:sgname]
		gpass = params[:sgpass]
		name = params[:sname]
		pass = params[:spass]
		x = params[:sx].to_f
		y = params[:sy].to_f

		game = Game.find_by(name: gname)
		if (game.nil? or (game.password != gpass))
			return
			# player did not log into the game with right credentials
		end

		player = game.players.find_by(name: name)

		if (player.nil?)
			Player.create(name: name, password: pass, game_id: game.id)
			player=Player.find_by(name: name)
			new_node = get_next_node(360,x,y,Node.all)
			if (new_node.nil?)
				return
				# player cannot join - Map is full
			end
			set_owner(player,new_node)
			return
		end

		if (player.password != pass)
			return
			# player did not log in with correct credentials
		end

		current = player.nodes.where(game: game).order(claimed_at: :desc).first
		possible = current.get_next_nodes
		tolerance = 3
		next_node = get_next_node(tolerance,x,y,possible)
		if next_node.nil?
			return
			# No node was in reach.
		end
		set_owner(player,next_node)
		error
	end

	def get_next_node(tolerance,x,y,possible)
		min = tolerance
		our_node = nil
		dist = 0
		possible.each do |n|
			dist = Connection.pytagoras(x,y,n.place.x,n.place.y)
			if ((dist < tolerance) and (dist < min) and (n.player_id.blank?))
				our_node = n
				min = dist
			end
		end
		return our_node
	end

	def set_owner(player, node)
		node.update_attributes(player_id: player.id)
		node.update_attributes(claimed_at: node.updated_at)
	end
end