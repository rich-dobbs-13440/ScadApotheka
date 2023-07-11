/* 
Provides a holder for a cheap roller limit switch, where the electrical connection 
is made using a m2 screws, nut, and a crimp-on ring connector.  Much less fussy that 
soldering wires to these small switches.

Usage:
use <ScadApotheka/no_solder_roller_limit_switch_holder.scad>

*/

include <ScadStoicheia/centerable.scad>
include <ScadApotheka/material_colors.scad>
include <ScadApotheka/roller_limit_switch.scad>

show_vitamins = false;
dx_mount_holes = 5;
dz_mount_holes = 4;
dx_connection = 8;
limit_switch = [20, 6.41, 10];

prong = [0.5, 3, 4];

module end_of_customization() {}

module no_solder_roller_limit_switch_holder() {
    back_plate = [limit_switch.x+4, 4, limit_switch.z/2 + prong.z + 4];
    top_plate = [limit_switch.x + 4, limit_switch.y + 4, 4];
    module mounting_screws(as_clearance=false) {
        center_reflect([1, 0, 0]) {
            translate([dx_mount_holes, 0, dz_mount_holes]) {
                rotate([90, 0, 0]) {
                    if (as_clearance) {
                        hole_through("M2", $fn=12, cld=0.4);
                    } else {
                        color(STAINLESS_STEEL) {
                            translate([0, 0, 3]) screw("M2x12", $fn=12);
                            translate([0, 0, -7.5]) nut("M2", $fn=12);
                        }
                    }
                }
            }
        }
    }
    module connection_screws(as_clearance=false) {
        module one_screw() {
            translate([0, 0, 13]) {
                rotate([0, 0, -90]) {        
                    if (as_clearance) {
                        hole_through("M2", $fn=12, cld=0.4);
                        translate([0, 0, -1])  nutcatch_sidecut(
                                name   = "M2",  // name of screw family (i.e. M3, M4, ...) 
                                l      = 50.0,  // length of slot
                                clk    =  0.5,  // key width clearance
                                clh    =  0.5,  // height clearance
                                clsl   =  0.1);                        
                    } else {
                        color(STAINLESS_STEEL) {
                            translate([0, 0, 6]) screw("M2x10", $fn=12);
                            translate([0, 0, -1.3]) nut("M2", $fn=12);
                            translate([0, 0, 1.8]) nut("M2", $fn=12);
                            translate([0, 0, 1.8 + 1.6 + 0.5]) nut("M2", $fn=12);
                        }  
                    } 
                }
            }
        }
        translate([-1, 0, 0]) one_screw();
        center_reflect([1, 0, 0]) {
            translate([dx_connection, 0, 0]) {
               one_screw(); 
            }
        }       
    }  
    module shape() {
        render(convexity=10) difference() {
            union() {
                translate([0, limit_switch.y/2, 0]) block(back_plate, center=ABOVE+RIGHT);
                translate([0, limit_switch.y/2 + 4, limit_switch.z/2 + prong.z]) block(top_plate, center=ABOVE+LEFT);
            }
            mounting_screws(as_clearance = true);
            connection_screws(as_clearance = true);
        }      
    }
    if (show_vitamins) {
        mounting_screws();
        connection_screws();
    }
    color(PART_33) {
        shape();
    }
    
}

if (show_vitamins) {
    roller_limit_switch();
}

no_solder_roller_limit_switch_holder();
