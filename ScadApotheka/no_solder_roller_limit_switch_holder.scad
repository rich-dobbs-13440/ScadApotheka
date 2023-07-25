/* 
Provides a holder for a cheap roller limit switch, where the electrical connection 
is made using a m2 screws, nut, and a crimp-on ring connector.  Much less fussy that 
soldering wires to these small switches.

Usage:
use <ScadApotheka/no_solder_roller_limit_switch_holder.scad>
nsrsh_top_clamp(
        show_vitamins=show_vitamins, 
        right_handed = true,
        alpha=1, 
        thickness=4, 
        use_dupont_pins = true);
nsrsh_ferrule_clamp(alpha = 1);

*/

include <ScadStoicheia/centerable.scad>
include <ScadApotheka/material_colors.scad>
use <ScadApotheka/roller_limit_switch.scad>
a_lot = 20 + 0;
/* [Output Control] */
show_vitamins = true;
switch_depressed = false;
show_top_clamp = true;
show_ferrule_clamp = false;
alpha_ferrule_clamp = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible]
alpha_back_plate = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible]

/* [Customization] */

right_handed_top_plate = true;
roller_arm_length = 20; //[18:short, 20: long]

/* [Design parameters] */
dx_connection = 8;
dx_ferrule_1 = -9.3;
dx_ferrule_2 = 0;
dx_ferrule_3 = 9.3;


plate_thickness = 1; // [0.5:test, 1, 2, 3, 4];
wall_ferrule = 2;
ferrule_16_awg = [1.9, 1.9, 8.5];
d_ferrule_16_awg = 4.4;
h_ferrule_16_awg = 6.7;
h_nut_block = 6;
dz_clamp_screws =8.5;

module end_of_customization() {}

function back_plate(thickness) = [rls_base().x, thickness, rls_base().z + rls_prong().z + 0.1 ];
function back_plate_translation() = [0, rls_base().y/2, -4];



if (show_ferrule_clamp) {
    nsrsh_ferrule_clamp(
        roller_arm_length = roller_arm_length,
        switch_depressed = switch_depressed,
        alpha = alpha_ferrule_clamp);
}
if (show_top_clamp) {
    nsrsh_top_clamp(
        right_handed = right_handed_top_plate, 
        alpha=alpha_back_plate, 
        thickness=plate_thickness, 
        roller_arm_length = roller_arm_length,
        switch_depressed = switch_depressed);
}

module roller_limit_switch_mounting_screws(as_clearance=false, adjustment_slot=false, for_ferrules=false, base_plate_thickness = 0) {
    limit_switch =  rls_base(); 
    nut_thickness = 2;
    required_length = limit_switch.y/2 + (for_ferrules ? wall_ferrule : 0) + base_plate_thickness + nut_thickness;
    screw_length = ceil(required_length / 2) * 2;
    screw_name = str("M2x", screw_length);
    center_reflect([1, 0, 0]) {
        translate(rls_mount_hole_translation()) {
            rotate([90, 0, 0]) {
                if (as_clearance) {
                    if (adjustment_slot) {
                        hull() {
                            hole_through("M2", $fn=12, cld=0.4);
                            translate([0, -4, 0]) hole_through("M2", $fn=12, cld=0.4);
                        }                        
                        
                    } else {
                        translate([0, 0, 25]) hole_through("M2", $fn=12, cld=0.4);
                    }
                } else {
                    color(STAINLESS_STEEL) {
                        if (for_ferrules) {
                            translate([0, 0, wall_ferrule+limit_switch.y/2]) screw(screw_name, $fn=12);
                        } else {
                            translate([0, 0, 3]) screw(screw_name, $fn=12);
                        }
                    } color(BLACK_IRON) {
                        translate([0, 0, -limit_switch.y/2 - base_plate_thickness]) nut("M2", $fn=12);
                    }
                }
            }
        }
    }
}

module nsrsh_ferrule_clamp(
        roller_arm_length = 20,
        switch_depressed = false, 
        alpha = 1) {
    limit_switch =  rls_base(); 
    prong = rls_prong();
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
        roller_limit_switch(roller_arm_length=roller_arm_length, switch_depressed=switch_depressed);
        ferrules();
        clamp_screws();
        roller_limit_switch_mounting_screws(for_ferrules=true);
    }
    color(PART_20, alpha) {
        shape();
    }
}

module nsrsh_slide_plate() {
}

module nsrsh_top_clamp(
        show_vitamins=show_vitamins, 
        right_handed = true,
        alpha=1, 
        thickness=4, 
        use_dupont_pins = true, 
        roller_arm_length = 20,
        switch_depressed = false) {
            
   limit_switch =  rls_base();  
   prong = rls_prong();
            
    top_plate = [limit_switch.x + 4, limit_switch.y + thickness, 9];

    module connection_screws(as_clearance=false) {
        screw_length = use_dupont_pins ? 6 : 10;
        screw_name = str("M2x", screw_length);
        dz =limit_switch.z/2 + prong.z + screw_length;  //  back_plate(thickness).z + back_plate_translation().z ;
        dz_nutcut = -screw_length + 3;
        module one_screw() {
            translate([0, 0, dz]) {  // back_plate_translation
                rotate([0, 0, -90]) {        
                    if (as_clearance) {
                        translate([0, 0, 10]) hole_through("M2", $fn=12, cld=0.4, l=screw_length + 1, h=10);
                        translate([0, 0, dz_nutcut])  {
                            nutcatch_sidecut(
                                name   = "M2",  // name of screw family (i.e. M3, M4, ...) 
                                l      = 50.0,  // length of slot
                                clk    =  0.5,  // key width clearance
                                clh    =  0.5,  // height clearance
                                clsl   =  0.1);      
                            if (use_dupont_pins) {
                               translate([0, 1.3, -0.1]) rod(d=1.2, l=a_lot, $fn=12);
                            }
                        }
                    } else {
                        color(STAINLESS_STEEL) {
                            translate([0, 0, -0.]) screw(screw_name, $fn=12);
                            translate([0, 0, dz_nutcut-0.4]) nut("M2", $fn=12);
                            if (use_dupont_pins) {
                                
                            } else {
                                translate([0, 0, 1.8]) nut("M2", $fn=12);
                                translate([0, 0, 1.8 + 1.6 + 0.5]) nut("M2", $fn=12);
                            }
                        }  
                    } 
                }
            }
        }
        for (dx = rls_dx_prongs()) {
            translate([dx, 0, 0]) one_screw();
        }      
    }  
    module shape() {
        top_plate_translation = [
            0, 
            limit_switch.y/2 + thickness, 
            limit_switch.z/2 + prong.z
        ];
        render(convexity=10) difference() {
            union() {
                translate(back_plate_translation()) block(back_plate(thickness), center=ABOVE+RIGHT);
                translate(top_plate_translation) block(top_plate, center=ABOVE+LEFT);
                for (dx = rls_dx_prongs()) {
                    translate([dx, 0, limit_switch.y+0.5]) {
                        center_reflect([1, 0, 0]) translate([0.5, 0, 0]) block([1, limit_switch.y, prong.z], center=ABOVE+FRONT);
                    }
                }
            }
            roller_limit_switch_mounting_screws(as_clearance = true);
            connection_screws(as_clearance = true);
        }      
    }
    module right_handed_part() {
        if (show_vitamins) {
            roller_limit_switch(roller_arm_length=roller_arm_length, switch_depressed=switch_depressed);   
            roller_limit_switch_mounting_screws(base_plate_thickness = thickness);
            connection_screws();

        }
        color(PART_33, alpha) {
            shape();
        }
    }
    if (right_handed) {
        right_handed_part();
    } else {
        mirror([0, 1, 0]) right_handed_part();
    }
    
}



