/*

Usage:

use <ScadApotheka/pca9685_slide_rail_mount.scad>

pca9685_slide_rail_mount();

*/ 

include <ScadStoicheia/centerable.scad>
include <ScadApotheka/material_colors.scad>
use <slide_rail_pcb_mount.scad>


/* [Output Control] */
fit_test = false;
show_vitamins = true;
alpha_mounting = 1; // [0:Invisible, 0.25:Ghostly, 1:Solid]

/* [Design] */

y_clearance = 0.25;
z_clearance = 0.25;
dy_servo_block = 0.25;

dx_holes = (1.23 - 0.13) * 25.4;
dy_holes = (0.88/2 - 0.13) * 25.4;
screw_terminal = [7.4, 8.0, 8.7];

module end_of_customization() {}

board = [62, 25.4, 1.6];
servo_block = [50.5, 3*2.54, 2.54];


pca9685_slide_rail_mount(center=FRONT, show_vitamins=show_vitamins);


module board_mounting_screws(as_clearance = false, as_board_clearance = false, dx_holes=dx_holes, dy_holes=dy_holes) {

    center_reflect([1, 0, 0]) center_reflect([0, 1, 0]) {
        translate([dx_holes, dy_holes, board.z]) {
            if (as_clearance) {
                translate([0, 0, 25]) hole_through("M2", $fn=12);
            } else if (as_board_clearance) {
                translate([0, 0, 25]) hole_through("M2.5", $fn=12);
            } else {
                color(BLACK_IRON) screw("M2x6", $fn=12);
            }
        }
    }
}


module board() {
    
    color("#003366") {
        render(convexity = 10) difference() {
            block(board, center=ABOVE);
            board_mounting_screws(as_board_clearance = true);
        }
    }
    board_mounting_screws(as_clearance = false);
    color("#7dd57f") {
        translate([0, board.y/2, board.z]) block(screw_terminal, center = ABOVE+LEFT);
    }
}

module pca9685_slide_rail_mount(
        dx_holes=dx_holes, 
        dy_holes=dy_holes, 
        dz_extra_under_board = 0,
        center=CENTER, 
        show_vitamins=true) {
            
    module servo_block_clearance() {
        y_rail_wall = 2;
        dx = 0;
        dz = 6;
        dy = -board.y/2 - dy_servo_block;
        translate([dx, dy, dz]) block(servo_block + [2, 0, 0], center = ABOVE+RIGHT); 
    }
    module screw_terminal_strain_relief(as_clearance=false) {
        if (as_clearance) {
            translate([0, board.y/2, 6]) {
                block([15, 8, 6], center=ABOVE);
            }
        } else {
            translate([0, board.y/2 + y_clearance, 0]) {
                difference() {
                    color("brown") {
                        block([0.4, 8, 12], center=ABOVE+RIGHT);
                        block([15, 8, 8], center=ABOVE+RIGHT);
                    }
                    center_reflect([1, 0, 0]) translate([5, 5, 0]) {
                        translate([0, 0, 25]) hole_through("M2", $fn=12);
                        translate([0, 0, 4])  nutcatch_sidecut(
                                                            "M2",
                                                            clk    =  0.5,  // key width clearance
                                                            clh    =  0.5  // height clearance
                                                        );
                    }
                }
            }
        }
    }
    module shape() {
        slide_rail_pcb_mount(
                board, 
                y_clearance,    
                z_clearance, 
                dz_extra_under_board=dz_extra_under_board, 
                breadboard_clip = true,
                mounting_screw_locations = [[15, 0, 0]],
                show_vitamins=show_vitamins) {
            board();
            union() {
            }
            union() {
                servo_block_clearance();
                board_mounting_screws(as_clearance = true, dx_holes=dx_holes, dy_holes=dy_holes);
                screw_terminal_strain_relief(as_clearance=true);
                if (fit_test) {
                    translate([-board.x/2 + 10, 0, 0]) plane_clearance(FRONT);
                }
            }
        }
        screw_terminal_strain_relief();
        
    }
    translation = 
        center == CENTER ? [0, 0, 0] : 
        center == FRONT ? [board.x/2, 0, 0] : 
        assert(FALSE);
    translate(translation) {
        shape(); 
    }
    
}



