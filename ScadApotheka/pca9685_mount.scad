include <ScadStoicheia/centerable.scad>
include <ScadApotheka/material_colors.scad>



/* [Output Control] */
fit_test = true;
show_board = true;

/* [Design] */
breadboard_offset = 12;
z_base =3;
y_rail_wall = 2;
y_rail_base = 3;
clearance = 0.25;
dz_board_bottom_clearance = 2;
z_lip = 1;

module end_of_customization() {}

board = [62.3, 25.2, 1.5];
base = [board.x, board.y + 2*clearance + 2*y_rail_wall , z_base];
rail_base = [board.x, y_rail_base, base.z + dz_board_bottom_clearance];
rail_wall = [
    board.x, 
    y_rail_wall, 
    base.z + dz_board_bottom_clearance + board.z + clearance + z_lip
];

dz_lip = rail_base.z + board.z;
lip_bottom = [board.x, y_rail_wall, clearance];
lip_top = [board.x, y_rail_wall + clearance, z_lip];
if (show_board) {
    board();
}
mounting();
//test_article();

module test_article() {
    dx_pcf = 45; // [40:0.1:45]
    dy_pcf = -11; // [-12:0.1:0]    
    translate([0, -board.y/2-6.8, 0])
    render(convexity = 10) difference() {
        translate([dx_pcf, dy_pcf,  0]) import("PCF8574_2_pieces_mount_5447531/files/PCF8574_2_pieces.stl");
        translate([20, 0, 0]) plane_clearance(FRONT);
        translate([0, 20, 0]) plane_clearance (RIGHT);
    }
}



module board() {
    translate([0, 0, z_base + dz_board_bottom_clearance]) color("#003366") block(board, center=ABOVE);
}

module mounting() {
    module blank() {
        block(base, center=ABOVE);
        center_reflect([0, 1, 0]) translate([0, base.y/2, 0]) block(rail_base, center=ABOVE+LEFT);
        center_reflect([0, 1, 0]) translate([0, base.y/2, 0]) block(rail_wall, center=ABOVE+LEFT);
        center_reflect([0, 1, 0]) translate([0, base.y/2, dz_lip]) hull() {
            block(lip_bottom, center=ABOVE+LEFT);
            translate([0, 0, clearance])  block(lip_top, center=ABOVE+LEFT);
        }
        
    }
    module holes() {
    }
    module shape() {
        render(convexity = 10) difference() {
            blank();
            holes();
            if (fit_test) {
                translate([board.x/2 - 10, 0, 0]) plane_clearance(BEHIND);
            }
        }
    }
    color(PART_15) {  
       shape(); 
    } 
    
}



