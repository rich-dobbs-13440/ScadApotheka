/*

Usage:

use <slide_rail_pcb_mount.scad>

slide_rail_pcb_mount(board[,  y_clearance=y_clearance_default][, z_clearance = z_clearance_default]) {
    additions();
    removals();
}

Both additions() and removals() must be provided, althouth they can be empty.

*/ 

include <ScadStoicheia/centerable.scad>
include <ScadApotheka/material_colors.scad>

/* [Output Control] */
fit_test = false;
show_board = true;
alpha_mounting = 1; // [0:Invisible, 0.25:Ghostly, 1:Solid]

/* [Design] */
//breadboard_offset = 12;
z_base = 3;
y_rail_wall = 2;
y_rail_base = 3;
y_clearance_default = 0.25;
z_clearance_default = 0.25;
dz_board_bottom_clearance = 2.5;
z_lip = 0.5;
y_lip = 0.25;


module end_of_customization() {}

sample_board = [47, 15.5, 1.6];

function sr_pcb_mt__base(board, y_clearance) = [board.x, board.y + 2*y_clearance + 2*y_rail_wall , z_base];
function sr_pcb_mt_rail_base(board, y_clearance) = [board.x, y_rail_base, sr_pcb_mt__base(board, y_clearance).z + dz_board_bottom_clearance];
function sr_pcb_mt_rail_wall(board, y_clearance, z_clearance) = [
    board.x, 
    y_rail_wall, 
    sr_pcb_mt__base(board, y_clearance).z + dz_board_bottom_clearance + board.z + z_clearance + z_lip
];

function sr_pcb_mt__dz_board()  = z_base + dz_board_bottom_clearance;


if (show_board) {
    sample_board();
}
slide_rail_pcb_mount(board=sample_board) {
    union(){};
    union(){};
}
////
//
module sample_board() {
    color("#003366") {
        render(convexity = 10) difference() {
            translate([0, 0, sr_pcb_mt__dz_board()]) block(sample_board, center=ABOVE);
        }
    }
}

module slide_rail_pcb_mount(
        board, 
        y_clearance=y_clearance_default, 
        z_clearance = z_clearance_default) {
    base = sr_pcb_mt__base(board, y_clearance);
    module rail() {
        rail_base = sr_pcb_mt_rail_base(board, y_clearance);
        rail_wall = sr_pcb_mt_rail_wall(board, y_clearance, z_clearance);
        dz_lip = rail_base.z + board.z;
        lip_bottom = [board.x, y_rail_wall, z_clearance];
        lip_top = [board.x, y_rail_wall + y_clearance + y_lip, z_lip];  
        block(rail_base, center=ABOVE+LEFT);
        block(rail_wall, center=ABOVE+LEFT);        
        translate([0, 0, dz_lip]) hull() {
            block(lip_bottom, center=ABOVE+LEFT);
            translate([0, 0, z_clearance+y_lip])  block(lip_top, center=ABOVE+LEFT);
        }
   }            
    module blank() {
        block(base, center=ABOVE);
        center_reflect([0, 1, 0]) translate([0, base.y/2, 0]) rail();
        
    }

    module shape() {
        render(convexity = 10) difference() {
            blank() {
                children(0);
            };
            children(1);
            if (fit_test) {
                translate([board.x/2 - 10, 0, 0]) plane_clearance(BEHIND);
            }
        }
    }
    color(PART_15, alpha=alpha_mounting) {  
       shape() {
           children(0);
           children(1);
       }
    }    
}