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
show_back_plate = true;
alpha_ferrule_clamp = 1; // [1:Solid, 0.25:Ghostly]

dx_mount_holes = 5;
dz_mount_holes = 4;
dx_connection = 8;
limit_switch = [20, 6.41, 10];
dx_ferrule_1 = -9.3;
dx_ferrule_2 = 0;
dx_ferrule_3 = 9.3;
prong = [0.5, 3, 5];

use_ferrules = true;
wall_ferrule = 2;
ferrule_16_awg = [1.9, 1.9, 8.5];
d_ferrule_16_awg = 4.4;
h_ferrule_16_awg = 6.7;
h_nut_block = 6;
dz_clamp_screws =8.5;

module end_of_customization() {}

function back_plate() = [limit_switch.x+4, 4, limit_switch.z + prong.z + 0.1 ];
function back_plate_translation() = [0, limit_switch.y/2, -4];

if (show_vitamins) {
    roller_limit_switch();    
}

if (use_ferrules) {
    nsrsh_ferrule_clamp();
}
if (show_back_plate) {
    no_solder_roller_limit_switch_holder(use_ferrules=use_ferrules);
}

module roller_limit_switch_mounting_screws(as_clearance=false, for_ferrules=false) {
    center_reflect([1, 0, 0]) {
        translate([dx_mount_holes, 0, dz_mount_holes]) {
            rotate([90, 0, 0]) {
                if (as_clearance) {
                    if (for_ferrules) {
                        translate([0, 0, 25]) hole_through("M2", $fn=12, cld=0.4);
                    } else {
                        hull() {
                            hole_through("M2", $fn=12, cld=0.4);
                            translate([0, -4, 0]) hole_through("M2", $fn=12, cld=0.4);
                        }
                    }
                } else {
                    color(STAINLESS_STEEL) {
                        if (for_ferrules) {
                            translate([0, 0, wall_ferrule+limit_switch.y/2]) screw("M2x16", $fn=12);
                        } else {
                            translate([0, 0, 3]) screw("M2x12", $fn=12);
                        }
                        translate([0, 0, -7.5]) nut("M2", $fn=12);
                    }
                }
            }
        }
    }
}

module nsrsh_ferrule_clamp() {
    front_plate = [
        limit_switch.x + 1, 
        wall_ferrule, 
        limit_switch.z/2 + ferrule_16_awg.z
    ];
    face_plate = [
        limit_switch.x + 2*h_nut_block + 1,
        limit_switch.y + wall_ferrule,
        ferrule_16_awg.z + 4
    ];   
    nut_block = [h_nut_block, face_plate.y,  h_nut_block];  
    module blank() {
        translate([0, -limit_switch.y/2, 0]) block(front_plate, center=ABOVE+LEFT);
        translate([0, limit_switch.y/2, limit_switch.z-prong.z + 2]) block(face_plate, center=ABOVE+LEFT); 
        center_reflect([1, 0, 0])  translate([face_plate.x/2, limit_switch.y/2, dz_clamp_screws])  block(nut_block, center=LEFT+BEHIND);      
    }
    module one_ferrule(as_clearance) {
        translate([0, 0, limit_switch.z/2]) {
            if (as_clearance) {
                block([5, 3.25, 24], center=ABOVE);
                translate([0, 0, ferrule_16_awg.z]) block([5, 5, 24], center=ABOVE);
            } else {
                color(STAINLESS_STEEL) block(ferrule_16_awg, center=ABOVE);
                translate([0, 0, ferrule_16_awg.z]) color("black") can(d=d_ferrule_16_awg, h = h_ferrule_16_awg, center=ABOVE);
                translate([0, 0, ferrule_16_awg.z]) color("red") can(d=1.5, h = 20,center=ABOVE);
            } 
        }       
    }
    module ferrules(as_clearance=false) {
        translate([dx_ferrule_1, 0, 0])  one_ferrule(as_clearance);
        if (as_clearance) {
            translate([dx_ferrule_2, 0, 0])  one_ferrule(as_clearance);
        }
        translate([dx_ferrule_3, 0, 0])  one_ferrule(as_clearance);
    }
    module clamp_screws(as_clearance=false) {
        dx_clamp_screws = face_plate.x/2;
        center_reflect([1, 0, 0]) {
            translate([dx_clamp_screws, 0, dz_clamp_screws]) {
                rotate([0, 90, 0]) {
                    if (as_clearance) {
                        translate([0, 0, 9]) hole_through("M2", $fn=12, cld=0.4, l=18);
                        rotate([0, 0, 90]) translate([0, 0, -2])  nutcatch_sidecut(
                                name   = "M2",  // name of screw family (i.e. M3, M4, ...) 
                                l      = 50.0,  // length of slot
                                clk    =  0.5,  // key width clearance
                                clh    =  0.5,  // height clearance
                                clsl   =  0.1);                         
                    } else {
                        color(STAINLESS_STEEL) {
                            screw("M2x6", $fn=12);
                        }
                        
                    }
                }
            }
        }        
    }
    module shape() {
        render(convexity=10) difference() {
            blank();
            ferrules(as_clearance=true);
            clamp_screws(as_clearance=true);
            roller_limit_switch_mounting_screws(as_clearance = true, for_ferrules=true);
        }        
    }
    if (show_vitamins) {
        ferrules();
        clamp_screws();
        roller_limit_switch_mounting_screws(for_ferrules=true);
    }
    color(PART_20, alpha = alpha_ferrule_clamp) {
        shape();
    }
}



module no_solder_roller_limit_switch_holder(show_vitamins=show_vitamins, use_ferrules=false) {
    top_plate = [limit_switch.x + 4, limit_switch.y + 4, 4];

    module connection_screws(as_clearance=false) {
        module one_screw() {
            translate([0, 0, back_plate().z-4]) {
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
                translate(back_plate_translation()) block(back_plate(), center=ABOVE+RIGHT);
                if (!use_ferrules) {
                    translate([0, limit_switch.y/2 + 4, limit_switch.z/2 + prong.z]) block(top_plate, center=ABOVE+LEFT);
                }
            }
            roller_limit_switch_mounting_screws(as_clearance = true);
            connection_screws(as_clearance = true);
        }      
    }
    if (show_vitamins) {
        roller_limit_switch_mounting_screws();
        if (!use_ferrules) {
            connection_screws();
        }

    }
    color(PART_33, alpha=0.25) {
        shape();
    }
    
}

if (show_vitamins) {
    
}


