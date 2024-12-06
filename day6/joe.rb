require 'set'  

class GuardPatrol
  DIRECTIONS = {
    up: [-1, 0],
    right: [0, 1],
    down: [1, 0],
    left: [0, -1]
  }

  def initialize(input)
    u/grid = input.strip.split("\n").map(&:chars)
    u/height = u/grid.length
    u/width = u/grid[0].length
    find_start_position
  end

  def find_start_position
    u/grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        if cell == '^'
          u/start_pos = [y, x]
          u/grid[y][x] = '.' # Clear the start position
          return
        end
      end
    end
  end

  def turn_right(direction)
    case direction
    when :up then :right
    when :right then :down
    when :down then :left
    when :left then :up
    end
  end

  def valid_position?(pos)
    y, x = pos
    y >= 0 && y < u/height && x >= 0 && x < u/width
  end

  def simulate_path(start_pos = u/start_pos, grid = u/grid)
    pos = start_pos.dup
    direction = :up
    visited = {pos => true}
    path = [pos.dup]
    
    loop do
      dy, dx = DIRECTIONS[direction]
      next_pos = [pos[0] + dy, pos[1] + dx]
      
      return [visited.keys, path] unless valid_position?(next_pos)
      
      if !valid_position?(next_pos) || grid[next_pos[0]][next_pos[1]] == '#'
        direction = turn_right(direction)
      else
        pos = next_pos
        path << pos.dup
        visited[pos] = true
        
        if pos[0] == 0 || pos[0] == u/height - 1 || pos[1] == 0 || pos[1] == u/width - 1
          next_pos = [pos[0] + dy, pos[1] + dx]
          return [visited.keys, path] unless valid_position?(next_pos)
        end
      end
    end
  end

  def check_for_loop(start_pos, grid)
    pos = start_pos.dup
    direction = :up
    state_history = {}  # Track [position, direction] states
    steps = 0
    max_steps = u/width * u/height * 4  # Maximum possible unique states
    
    loop do
      state = [pos, direction]
      return true if state_history[state]  # Found a loop
      return false if steps > max_steps    # Too many steps, probably no loop
      
      state_history[state] = true
      steps += 1
      
      dy, dx = DIRECTIONS[direction]
      next_pos = [pos[0] + dy, pos[1] + dx]
      
      return false unless valid_position?(next_pos)  # Left the grid
      
      if !valid_position?(next_pos) || grid[next_pos[0]][next_pos[1]] == '#'
        direction = turn_right(direction)
      else
        pos = next_pos
      end
    end
  end

  def find_loop_positions
    loop_positions = []
    original_path = Set.new(simulate_path[0])  # Create Set directly from array
    
    # Only try positions that were in the original path
    original_path.each do |y, x|
      next if [y, x] == u/start_pos
      
      test_grid = u/grid.map(&:dup)
      test_grid[y][x] = '#'
      
      if check_for_loop(@start_pos, test_grid)
        loop_positions << [y, x]
      end
    end
    
    loop_positions
  end

  def count_visited_positions
    visited, _ = simulate_path  # Fixed syntax
    visited.length
  end

  def count_loop_positions
    find_loop_positions.length
  end
end

# Process input and solve both parts
input = File.read('input.txt')
guard = GuardPatrol.new(input)

puts "Part 1: #{guard.count_visited_positions}"
puts "Part 2: #{guard.count_loop_positions}"
