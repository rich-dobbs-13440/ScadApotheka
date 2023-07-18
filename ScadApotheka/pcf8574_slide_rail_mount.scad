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
x_board = 47;

module end_of_customization() {}

one_board = [x_board, 15.5, 1.6];

pcf8574_slide_rail_mount(board_count, center=FRONT, show_vitamins=show_vitamins);

//for (i = [1:4]) {
//    translate([0, i*30, 0]) board(board_count=i);
//}

module board(board_count) {
    pin_header = [8*0.1*25.4, 0.1*25.4, 0.1*25.4];
    dz_header = one_board.z;
    dy_header = one_board.y/2 - 0.5;
    offset = -(board_count-1) * x_board / 2;
    for (i = [0 : board_count-1]) { 
        dx = offset + i * one_board.x; 
        translate([dx, 0, 0]) {
            color("#003366") {
                    block(one_board, center=ABOVE);
            }
            color("yellow") {
                translate([0, dy_header, dz_header]) block(pin_header, center=ABOVE+LEFT);
            }
        }
    }
}

module pcf8574_slide_rail_mount(
        board_count = 1,    
        dz_extra_under_board = 0,
        center=CENTER, 
        show_vitamins=true) {
    board = [board_count*one_board.x, one_board.y, one_board.z];
    module servo_block_clearance() {
        y_rail_wall = 2;
        dz = 6;
        dy = board.y/2 - dy_servo_block;
        translate([5, dy, dz]) block(servo_block + [10, 0, 0], center = ABOVE+LEFT); 
    }
    module shape() {
        slide_rail_pcb_mount(
                board, 
                y_clearance, 
                z_clearance, 
                dz_extra_under_board=dz_extra_under_board, 
                show_vitamins=show_vitamins) {
            board(board_count);
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
        shape(); 
    }
}



