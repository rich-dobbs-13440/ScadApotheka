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

module end_of_customization() {}

board = [62, 25.4, 1.6];
servo_block = [50.5, 3*2.54, 2.54];


pca9685_slide_rail_mount(center=FRONT, show_vitamins=show_vitamins);


module board_mounting_screws(as_clearance = false, as_board_clearance = false, dx_holes=dx_holes, dy_holes=dy_holes) {

    center_reflect([1, 0, 0]) center_reflect([0, 1, 0]) {
        translate([dx_holes, dy_holes, sr_pcb_mt__dz_board() + board.z]) {
            if (as_clearance) {
                hole_through("M2", $fn=12);
            } else if (as_board_clearance) {
                hole_through("M2.5", $fn=12);
            } else {
                color(BLACK_IRON) screw("M2x6", $fn=12);
            }
        }
    }
}


module board() {
    color("#003366") {
        render(convexity = 10) difference() {
            translate([0, 0, sr_pcb_mt__dz_board()]) block(board, center=ABOVE);
            board_mounting_screws(as_board_clearance = true);
        }
    }
    board_mounting_screws(as_clearance = false);
}

module pca9685_slide_rail_mount(
        dx_holes=dx_holes, 
        dy_holes=dy_holes, 
        center=CENTER, 
        show_vitamins=true) {
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
                servo_block_clearance();
                board_mounting_screws(as_clearance = true, dx_holes=dx_holes, dy_holes=dy_holes);
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
            board();
        }        
        color(PART_16, alpha=alpha_mounting) {  
           shape(); 
        } 
    }
    
}



