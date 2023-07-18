/*

Usage:

use <ScadApotheka/pcf8574_slide_rail_mount.scad>

pcf8574_slide_rail_mount();

*/ 

include <ScadStoicheia/centerable.scad>
include <ScadApotheka/material_colors.scad>
use <slide_rail_pcb_mount.scad>


/* [Output Control] */
fit_test = false;
show_vitamins = true;
alpha_mounting = 1; // [0:Invisible, 0.25:Ghostly, 1:Solid]
board_count = 1; // [1:4]

/* [Design] */

y_clearance = 0.25;
z_clearance = 0.25;
dy_servo_block = 0.25;

module end_of_customization() {}

function board_extent(board_count) = [47 *board_count , 15.5, 1.6];

//if (show_board) {
//    board(board_count);
//}
pcf8574_slide_rail_mount(board_count, center=FRONT, show_vitamins=show_vitamins);



module board(board_count) {
    board = board_extent(board_count) ;
    color("#003366") {
        render(convexity = 10) difference() {
            translate([0, 0, sr_pcb_mt__dz_board()]) block(board, center=ABOVE);
        }
    }
}

module pcf8574_slide_rail_mount(
        board_count = 1,         
        center=CENTER, 
        show_vitamins=true) {
    board = board_extent(board_count) ;
    module servo_block_clearance() {
        y_rail_wall = 2;
        dz = 6;
        dy = board.y/2 - dy_servo_block;
        translate([5, dy, dz]) block(servo_block + [10, 0, 0], center = ABOVE+LEFT); 
    }
    module shape() {
        slide_rail_pcb_mount(board, y_clearance, z_clearance) {
            union() {
            }
            union() {
                if (fit_test) {
                    translate([board.x/2 - 10, 0, 0]) plane_clearance(BEHIND);
                }
            }
        }
    }
    translation = 
        center == CENTER ? [0, 0, 0] : 
        center == FRONT ? [board.x/2, 0, 0] : 
        assert(FALSE);
    translate(translation) {
        if (show_vitamins) {
            board(board_count);
        }        
        color(PART_15, alpha=alpha_mounting) {  
           shape(); 
        } 
    }
}



