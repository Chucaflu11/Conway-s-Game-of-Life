module main

import gg
import gx

const (

    w_width = 800
    w_height = 400
    res = 10

    columns = int(w_width / res)
    rows = int(w_height / res)

)

enum TextType {
    pause
    drawing
}

enum State {
    drawing
    running
    paused
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
        window_title: 'Game of Life'
        user_data: game
        resizable: false //Doesn't work
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

    mut x_mouse := game.gg.mouse_pos_x
    mut y_mouse := game.gg.mouse_pos_y
    mut m_button := game.gg.mouse_buttons

    mut x_index := 0
    mut y_index := 0

    mut out_of_range := x_mouse < 0 || x_mouse > 800 || y_mouse < 0 || y_mouse > 400

    if (m_button == .left) && (!out_of_range){
        x_index = int(x_mouse/res)
        y_index = int(y_mouse/res)
        game.cells[x_index][y_index] = 1
    }
}

fn (mut game Game) get_keys(){

    if game.gg.pressed_keys[32] {   //key 32 = space
        if game.game_state == .drawing {
            game.game_state = .running
        }
        else if game.game_state == .running{
            game.game_state = .drawing
        }
        else if game.game_state == .paused{
            game.game_state = .running
        }
    }

    if game.gg.pressed_keys[256] {  //key 256 = esc
        game.game_state = .paused
    }

}

fn (mut game Game) text_format (text TextType) gx.TextCfg {

    match text {
        .pause {
            return gx.TextCfg{
                color:          gx.black
	            size:           64
	            align:          .center
	            vertical_align: .middle
            }
        }
        .drawing {
            return gx.TextCfg{
                color:          gx.black
	            size:           16
	            align:          .center
            }
        }
    }
}

fn (mut game Game) draw(){

    mut color := gx.white
    
    if game.gg.frame & 5 == 0{
        game.get_keys()
    }
    
    for i in 0 .. columns {
        for j in 0 .. rows {
            
            if game.cells[i][j] == 1{
                color = gx.black
            }
            //1px border
            game.gg.draw_rect_filled(i*res, j*res, res-1, res-1, color)
            color = gx.white
        }

    }

    
    if game.game_state == .drawing{
        game.gg.draw_text(w_width / 4, res, "Space: Play", game.text_format(.drawing))
        game.gg.draw_text(w_width / 2, res, "Left Click to draw", game.text_format(.drawing))
        game.gg.draw_text(w_width - (w_width / 4), res, "Esc: Pause", game.text_format(.drawing))
        game.mouse_draw()
    }
    if (game.gg.frame & 15 == 0) && (game.game_state == .running) {
		game.update_cells()
	}
    if game.game_state == .paused {
        game.gg.draw_text(w_width / 2, w_height / 2, "Game Paused", game.text_format(.pause))
    }

}

fn (mut game Game) init_game() {

    mut list := [][]int{len: columns, init: []int{len: rows}}

    for i := 0; i < columns; i++ {
        for j := 0; j < rows; j++ {
            list[i][j] = 0
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