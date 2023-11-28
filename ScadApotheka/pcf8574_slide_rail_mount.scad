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
board_count = 1.0; // [1:1.0:4]
breadboard_clip = true;
dz_extra_under_board = 0;

/* [Design] */

y_clearance = 0.25;
z_clearance = 0.25;
dy_servo_block = 0.25;
// Edge to edge for the Dupont headers
x_board = 48.5;
// How much smaller is the PCB lengthwise, then the headers - Make larger than actual for visualization
dx_pcb = 1; // 0.4;


module end_of_customization() {}
one_board = [x_board, 15.5, 1.6];
pcb_board = one_board - [dx_pcb, 0, 0];

pcf8574_slide_rail_mount(
    board_count, 
    center=FRONT, 
    dz_extra_under_board = dz_extra_under_board,
    breadboard_clip=breadboard_clip, 
    show_vitamins=show_vitamins);

//for (i = [1:4]) {
//    translate([0, i*30, 0]) board(board_count=i);
//}

module board(board_count) {
    pin_header = [8*0.1*25.4, 0.1*25.4, 0.1*25.4];
    dz_header = one_board.z;
    dy_header = one_board.y/2 - 0.5;
    offset = -(board_count-1) * x_board / 2;
    // Thickness of breadboard and backer
    
    for (i = [0 : board_count-1]) { 
        dx = offset + i * one_board.x; 
        translate([dx, 0, 0]) {
            color("#003366") {
                block(pcb_board, center=ABOVE);
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
        breadboard_clip = true,
        show_vitamins=true, 
        ) {
     
    board = [board_count*one_board.x, one_board.y, one_board.z];
    module shape() {
        difference() {
            slide_rail_pcb_mount(
                    board, 
                    y_clearance, 
                    z_clearance, 
                    dz_extra_under_board=dz_extra_under_board, 
                    mounting_screw_locations =[[17, 0, 0]],
                    breadboard_clip=breadboard_clip,
                    show_vitamins=show_vitamins);
            if (fit_test) {
                translate([-board.x/2 + 10, 0, 0]) plane_clearance(FRONT);
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



