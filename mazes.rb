require 'set'
require 'pry'

class OrthoMaze
    def initialize(nrows: 20, ncols: 20)
        @cells = Array.new(nrows) {Array.new(ncols, :empty)}
        @nrows = nrows
        @ncols = ncols
    end

    def set_cell(i, j, val)
        @cells[i][j] = val
    end

    def cell(i, j)
        @cells[i][j]
    end

    def include?(cell)
        i, j = cell
        (0...@nrows).include?(i) && (0...@ncols).include?(j)
    end

    def look(i, j)
        result = {}
        result[:top] = @cells[i - 1][j] if i > 0
        result[:right] = @cells[i][j + 1] if j < @ncols - 1
        result[:bottom] = @cells[i + 1][j] if i < @nrows - 1
        result[:left] = @cells[i][j - 1] if j < 0
        result
    end

    def neighbours(i, j)
        cells = Set.new [[i - 1, j], [i, j + 1], [i + 1, j], [i, j - 1]]
        cells.select(&method(:include?))
    end

    def reflect(reference_cell, mirror_cell)
        # Because we treat cells and walls the same,
        # the neighbours of a space cell can be a wall cell.
        # To see whats on the other side, we need to go one more space
        # away from the origin cell.
        row, col = reference_cell
        mir_row, mir_col = mirror_cell
        new_row = row + (mir_row - row) * 2
        new_col = col + (mir_col - col) * 2

        if include?([new_row, new_col])
            [new_row, new_col]
        else
            nil
        end
    end

    def set_vertical_line(rows:, col:, value:)
        rows.each do |i|
            set_cell(i, col, value)
        end
    end

    def set_horizontal_line(row:, cols:, value:)
        cols.each do |j|
            set_cell(row, j, value)
        end
    end

    def outlined(value = :wall)
        set_vertical_line(rows: 0...@nrows, col: 0, value: value)
        set_vertical_line(rows: 0...@nrows, col: @ncols - 1, value: value)
        set_horizontal_line(cols: 1...@ncols - 1, row: 0, value: value)
        set_horizontal_line(cols: 1...@ncols - 1, row: @nrows - 1, value: value)

        self
    end

    def add_grid
        wall_h = false
        wall_v = false
        (1...@nrows).each do |row|
            (1...@ncols).each do |col|
                if wall_h || wall_v
                    set_cell(row, col, :wall)
                end
                wall_v = !wall_v
            end
            wall_h = !wall_h
        end
    end

    def each_line
        @cells.each do |line|
            yield line.dup
        end
    end
end

class OrthoMazeConsolePrinter
    CELL_MAP = {
        wall: '[ ]',
        empty: '   ',
    }

    def initialize(maze)
        @maze = maze
    end

    def print(out: STDOUT)
        @maze.each_line do |line|
            print_line(line, out: out)
        end
    end

    def print_line(line, out: STDOUT)
        puts(line.map {|cell| CELL_MAP[cell]}.join)
    end
end

class RecursiveBacktrackerGenerator
    def initialize(maze)
        @maze = maze
        @stack = []
        @seen = Set.new
    end

    def done?
        @stack.empty?
    end

    def carvable_walls
        current_cell = @stack.last
        walls = @maze.neighbours(*current_cell).select {|cell| @maze.cell(*cell) == :wall}
        targets = {}
        walls.each do |wall|
            target = @maze.reflect(current_cell, wall)
            targets[wall] = target unless target.nil? or @seen.include?(target)
        end
        targets
    end

    def backtrack
        @stack.pop
    end

    def carve_tunnel(wall, target)
        @maze.set_cell(wall.first, wall.last, :empty)
        @seen.add(target)
        @stack << target
    end

    def step
        targets = carvable_walls
        if targets.empty?
            @stack.pop
        else
            wall = targets.keys.sample
            target = targets[wall]
            carve_tunnel(wall, target)
        end

    end

    def generate
        @maze.add_grid

        until done?
            step
        end
    end

    def self.generate(maze)
        generator = self.new(maze)
        generator.carve_tunnel([0, 1], [1, 1])
        generator.generate
    end
end

maze = OrthoMaze.new.outlined
maze.add_grid
printer = OrthoMazeConsolePrinter.new(maze)
RecursiveBacktrackerGenerator.generate(maze)
printer.print
