class OrthoMaze
    def initialize(nrows: 10, ncols: 10)
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

    def neighbours(i, j)
        result = {}
        result[:top] = @cells[i - 1][j] if i > 0
        result[:right] = @cells[i][j + 1] if j < @ncols - 1
        result[:bottom] = @cells[i + 1][j] if i < @nrows - 1
        result[:left] = @cells[i][j - 1] if j < 0
        result
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

    def each_line
        @cells.each do |line|
            yield line.dup
        end
    end
end

class OrthoMazeConsolePrinter
    CELL_MAP = {
        wall: '##',
        empty: '  ',
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

maze = OrthoMaze.new.outlined
printer = OrthoMazeConsolePrinter.new(maze)
printer.print
