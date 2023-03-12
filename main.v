module main

import gg
import gx
import rand

const (

    w_width = 800
    w_height = 400
    res = 10

    columns = int(w_width / res)
    rows = int(w_height / res)

)

enum State {
    drawing
    running
}

struct Game {
mut:
    gg      &gg.Context = unsafe { nil }
pub mut:
    cells       [][]int
    game_state  State
}


fn main() {
    mut game := &Game{
        gg: 0
    }
    game.gg = gg.new_context(
        bg_color: gx.rgb(240, 240, 240)
        width: w_width
        height: w_height
        create_window: true
        window_title: 'Some title'
        user_data: game //what this does¿?¿?¿? (if I try to get it out of the code it jumps out a RUNTIME ERROR for some reason)
        resizable: false //Does this works?? XDD
        frame_fn: frame
    )
    game.init_game()
    game.gg.run()
    
}

fn frame(mut game Game) {
    game.gg.begin()
	game.draw()
    game.gg.end()
}

fn (mut game Game) mouse_draw() {

    

}

fn (mut game Game) draw(){

    mut color := gx.white
    for i in 0 .. columns {
        for j in 0 .. rows {
            
            if game.cells[i][j] == 1{
                color = gx.black
            }
            //Pading of 1px to make borders for each square
            game.gg.draw_rect_filled(i*res, j*res, res-1, res-1, color)
            color = gx.white
        }

    }
    if (game.gg.frame & 15 == 0) && (game.game_state == .running) {
		game.update_cells()
	}

}

fn (mut game Game) init_game() {

    // Some 2DArray with the game...
    mut list := [][]int{len: columns, init: []int{len: rows}}

    for i := 0; i < columns; i++ {
        for j := 0; j < rows; j++ {
            list[i][j] = 0  //rand.intn(2) or { 0 }  //Random numer between 0 and 1 (?¿?¿?)
        }
    }
    game.cells = list.clone()
    game.game_state = .drawing
}


/*
- Any live cell with two or three live neighbours survives.
- Any dead cell with three live neighbours becomes a live cell.
- All other live cells die in the next generation. Similarly, all other dead cells stay dead.
*/
fn (mut game Game) update_cells() {

    mut next_cells := [][]int{len: columns, init: []int{len: rows}}
    for i in 0 .. columns-1 {
        for j in 0 .. rows-1 {
            actual_cell := game.cells[i][j]
            alive_neighbors := game.count_alive_neighbors(i, j)
            if actual_cell == 0 && alive_neighbors == 3{
                next_cells[i][j] = 1
            }else if actual_cell== 1 && (alive_neighbors < 2 || alive_neighbors > 3){
                next_cells[i][j] = 0
            }
            else{
                next_cells[i][j] = actual_cell
            }

        }
    }
    game.cells = next_cells

}

fn (mut game Game) count_alive_neighbors(x int, y int) int{

    mut alive_neighbors := 0
    mut actual_col := 0
    mut actual_row := 0

    for i := -1; i < 2; i++{
        for j := -1; j < 2; j++{
            actual_col = (x + i + columns) % columns
            actual_row = (y + j + rows) % rows
            alive_neighbors += game.cells[actual_col][actual_row]
        }
    }
    alive_neighbors -= game.cells[x][y]
    return alive_neighbors

}