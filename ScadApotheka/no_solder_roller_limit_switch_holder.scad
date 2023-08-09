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
        use_dupont_connectors = true);
nsrsh_ferrule_clamp(alpha = 1);

*/

include <ScadStoicheia/centerable.scad>
use <ScadStoicheia/visualization.scad>
include <ScadApotheka/material_colors.scad>
use <ScadApotheka/roller_limit_switch.scad>
use <ScadApotheka/dupont_pins.scad>

a_lot = 100 + 0;
/* [Output Control] */
 mode = 3; // [3: "Assembly", 4: "Printing"]
 
show_vitamins = true;
switch_depressed = false;
show_terminal_end_clamp = true;
show_adjuster = true;
show_adjustable_mount = true;
show_adjustable_mount_clip = true;
show_ferrule_clamp = false;

adjuster  = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible]
adjustable_mount  = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible]
alpha_ferrule_clamp = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible]
alpha_terminal_end_clamp = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible]

/* [Animation] */

dz_adjustable_mount = -8; // [-8, -14]

/* [Printing] */
print_one_part = false;
part_to_print = "barrel"; // [barrel]



/* [Customization] */
recess_mounting_screws = true;
right_handed_terminal_end_clamp = true;
roller_arm_length = 20; //[18:short, 20: long]
trim_support = true;
adjustment_rails = true;
adjuster_screw_length = 20;


dz_mount = mode_is_printing(mode) ? -50: dz_adjustable_mount;

/* [Design parameters] */
dx_connection = 8;
dx_ferrule_1 = -9.3;
dx_ferrule_2 = 0;
dx_ferrule_3 = 9.3;


plate_thickness = 4; // [0.5:test, 1, 2, 3, 4];
wall_ferrule = 2;
ferrule_16_awg = [1.9, 1.9, 8.5];
d_ferrule_16_awg = 4.4;
h_ferrule_16_awg = 6.7;
h_nut_block = 6;
dz_clamp_screws = 8.5;

/* [Adjuster Design parameters] */
adjuster_plate_thickness = 4;
adjuster_slide_length = 30; // [10:40]
adjustable_mount_slide_length = 12;
dy_adjuster_screw = -4.5;
h_swivel_play = 0.5;

module end_of_customization() {}

function show(variable, name) = 
    (print_one_part && mode_is_printing(mode)) ? name == part_to_print :
    variable;

visualization_adjuster  =        
    visualize_info(
        "Adjuster", PART_2, show(adjuster, "adjuster") , layout_from_mode(mode)); 

visualization_adjustable_mount = 
    visualize_info(
        "Adjustable Mount ", PART_3, show(adjustable_mount , "adjustable_mount ") , layout_from_mode(mode)); 

function mounting_plate(thickness) = [rls_base().x, thickness, rls_base().z + rls_prong().z + 0.1 ];
function mounting_plate_translation() = [0, rls_base().y/2, -4];



if (show_ferrule_clamp) {
    nsrsh_ferrule_clamp(
        roller_arm_length = roller_arm_length,
        switch_depressed = switch_depressed,
        alpha = alpha_ferrule_clamp);
}

if (show_terminal_end_clamp) {
    nsrsh_terminal_end_clamp(
        right_handed = right_handed_terminal_end_clamp, 
        alpha=alpha_terminal_end_clamp, 
        recess_mounting_screws = recess_mounting_screws,
        thickness=plate_thickness, 
        adjustment_rails = adjustment_rails,
        roller_arm_length = roller_arm_length,
        switch_depressed = switch_depressed);
}

if (show_adjuster) {
    nsrsh_adjuster(show_vitamins=show_vitamins, screw_length=adjuster_screw_length, slide_length=adjuster_slide_length);
}


if (show_adjustable_mount) {
    nsrsh_adjustable_mount(
        show_vitamins=show_vitamins, 
        screw_length=adjuster_screw_length,
        slide_length = adjustable_mount_slide_length);
}

if (show_adjustable_mount_clip) {
    translate([0, 0, -10]) nsrsh_adjustable_mount_clip();
}




module nsrsh_adjustment_screw(
        as_clearance = false, 
        as_swivel_clearance = false,
        as_vitamins = false,
        as_nut_block = false,
        z_exposure = 10,
        screw_length=20) {
    screw_name = str("M2x", screw_length);
    dz_nutcut = -1.5;
    nut_block = [6, 6, 5]; // Thin up and down, low stress on these screws. Keep as much adjustment as possible.
    if (as_clearance) {
        translate([0, 0, 10]) hole_through("M2", $fn=12, cld=0.4, h=10);
        rotate([0, 0, -90]) {  
            translate([0, 0, dz_nutcut])  {
                nutcatch_sidecut(
                    name   = "M2",  // name of screw family (i.e. M3, M4, ...) 
                    l      = 50.0,  // length of slot
                    clk    =  0.25,  // key width clearance
                    clh    =  0.5,  // height clearance
                    clsl   =  0.5); 
            }
        }   
    } else if (as_swivel_clearance) {  
        hull() {
            can(d=5, h=2* 1.6 + h_swivel_play);
            translate([0, -5, 0]) can(d=5, h=2* 1.6 + h_swivel_play);
        }
        hull() {
            can(d=2, h=a_lot);
            translate([0, -5, 0]) can(d=2, h=a_lot);
        }        
        
    } else if (as_vitamins) {
        color(STAINLESS_STEEL) {
            translate([0, 0, dz_nutcut-0.4]) nut("M2", $fn=12); 
            translate([0, 0, screw_length - z_exposure]) {
                screw(screw_name, $fn=12); 
                nut("M2", $fn=12); 
                translate([0, 0, 1.6]) nut("M2", $fn=12);
            }
        }                
    } else if (as_nut_block) {
        block(nut_block, center=BELOW);
    }            
} 



module nsrsh_adjustable_mount_clip(as_clearance = false, show_vitamins=false, screw_length = 20) {
    clip = [8, 8, 8];
    limit_switch =  rls_base(); 
    module dovetail() {
        hull() {
            block(clip + [-2, 0, 0], center=BELOW);
            translate([0, 0, -clip.z]) block([clip.x, clip.y, 0.1], center = ABOVE);   
        }             
    }
    if (as_clearance) {
         translate([0, -clip.y/2, -clip.z/2]) dovetail();
    } else {

        translate([0, -limit_switch.y/2 - clip.y/2, 0]) {
            if (show_vitamins) {
                //translate([0, 0, -clip.z/2]) 
                nsrsh_adjustment_screw(as_vitamins=true);
            }            
            render(convexity = 10) difference() {
                dovetail();
                translate([0, 0, -clip.z/2]) nsrsh_adjustment_screw(as_swivel_clearance=true);
            }
        }
    }
}

    
module nsrsh_adjustable_mount(
        show_vitamins = false, 
        screw_length = 20, 
        as_slide_clearance=false, 
        slide_clearance = 0.2, 
        slide_length = 10) {
    limit_switch =  rls_base(); 
    z_slide = slide_length;
    s_slide = 10;

    
    module slide(as_clearance = false) {
        s = as_clearance ? s_slide + 2*slide_clearance: s_slide;
        z = as_clearance ? a_lot : z_slide;

        translate([0, -2, 0]) {
            intersection() {
                hull() {
                    rotate([0, 0, 45]) block([s, s, z], center=BELOW);
                    translate([0, -4, 0]) rotate([0, 0, 45]) block([s, s, z], center=BELOW);
                }
                translate([0, -2, 0]) block([a_lot, 8, a_lot]);
            }
        }
    }
    module shape() {
        render(convexity =10) difference() {
            translate([0, 0, +1.4]) slide(as_clearance = false);
            translate([0, 0, z_slide/2]) nsrsh_adjustable_mount_clip(as_clearance = true);
        }
    } 
    if (as_slide_clearance) {
        slide(as_clearance = true) ;
    } else {
        translate([0, -limit_switch.y/2, dz_mount]) {
            if (show_vitamins) {
                //nsrsh_adjustment_screw(as_vitamins = true, screw_length=screw_length, z_exposure=10);
            }
            visualize(visualization_adjustable_mount) {
                shape();
            }
        }
    }
}


module nsrsh_adjuster(show_vitamins=true, screw_length=20, slide_length=10, dz_adjuster_screw = 3.5) {
    limit_switch = rls_base();
    dz_slide = dz_adjuster_screw -5;
    screw_translation = [0, dy_adjuster_screw, dz_adjuster_screw];
    module mount_and_rails(dz_slide, slide_length) {

        mounting_plate = [limit_switch.x, adjuster_plate_thickness, limit_switch.z/2];
        slide_body =  [limit_switch.x, 8, slide_length];
        translate([0, 0, 1])  block(mounting_plate,  center= ABOVE + LEFT);        
        render(convexity=10) difference() {
            translate([0, 0, dz_adjuster_screw])  block(slide_body, center = BELOW + LEFT);
            translate([0, 0, dz_slide]) nsrsh_adjustable_mount(as_slide_clearance=true);
        }

    }
    module shape() {
        render(convexity=10) difference() {
             union() {
                mount_and_rails(dz_slide=dz_slide, slide_length =slide_length);
                translate(screw_translation) nsrsh_adjustment_screw(as_nut_block = true); 
            }
           roller_limit_switch_mounting_screws(as_clearance = true, recess_nut = true);
            translate(screw_translation) nsrsh_adjustment_screw(as_clearance = true);
        }
    }
    translate([0, -limit_switch.y/2, 0]) {
        if (show_vitamins && !mode_is_printing(mode)) {
            //translate(screw_translation) nsrsh_adjustment_screw(as_clearance = false, screw_length=screw_length);
        }
        visualize(visualization_adjuster) {
            shape();
        }
    }
}


module roller_limit_switch_mounting_screws(
        as_clearance=false, 
        adjustment_slot=false, 
        for_ferrules=false, 
        base_plate_thickness = 0, 
        recess = false, 
        recess_nut = false) {
    echo("base_plate_thickness", base_plate_thickness);
    limit_switch =  rls_base(); 
    nut_thickness = 2;
    required_length = limit_switch.y/2 + (for_ferrules ? wall_ferrule : 0) + base_plate_thickness + nut_thickness;
    screw_length = ceil(required_length / 2) * 2;
    screw_name = str("M2x", screw_length);
    dz_screws = 
        for_ferrules ? limit_switch.y/2 :
        recess ?  limit_switch.y/2 + 2:
        limit_switch.y/2 + base_plate_thickness;
    dz_nut = for_ferrules ? -limit_switch.y/2 - base_plate_thickness : -limit_switch.y/2;
    center_reflect([1, 0, 0]) {
        translate(rls_mount_hole_translation()) {
            rotate([-90, 0, 0]) {
                if (as_clearance) {
                    if (adjustment_slot) {
                        hull() {
                            hole_through("M2", $fn=12, cld=0.4);
                            translate([0, -4, 0]) hole_through("M2", $fn=12, cld=0.4);
                        }                        
                        
                    } else {
                        h = recess ? 10 : 0;
                        dz_extra = recess ? 0 : 25;
                        translate([0, 0, dz_screws + h + dz_extra]) hole_through("M2", h=h, $fn=12, cld=0.4);
                    }
                    if (recess_nut) {
                        translate([0, 0, -2]) nutcatch_parallel(
                            name   = "M2",  // name of screw family (i.e. M3, M4, ...)
                            clh    =  10,  // nut height clearance
                            clk    =  0.2);  // clearance aditional to nominal key width
                    }
                } else {
                    color(STAINLESS_STEEL) {
                        translate([0, 0, dz_screws]) screw(screw_name, $fn=12);
                    } 
                    color(STAINLESS_STEEL) {
                        translate([0, 0,  dz_nut]) nut("M2", $fn=12);
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
    if (show_vitamins && !mode_is_printing(mode)) {
        roller_limit_switch(roller_arm_length=roller_arm_length, switch_depressed=switch_depressed);
        ferrules();
        clamp_screws();
        roller_limit_switch_mounting_screws(for_ferrules = true, base_plate_thickness = wall_ferrule);
    }
    color(PART_20, alpha) {
        shape();
    }
}



module nsrsh_terminal_end_clamp(
        show_vitamins=show_vitamins, 
        right_handed = true,
        alpha=1, 
        thickness=4, 
        recess_mounting_screws = false,
        adjustment_rails = false,
        use_dupont_connectors = true, 
        roller_arm_length = 20,
        switch_depressed = false, 
        trim_base = false) {
            
   limit_switch =  rls_base();  
   prong = rls_prong();
            
    terminal_block = [limit_switch.x + 4, limit_switch.y + thickness, 9];
    screw_length = use_dupont_connectors ? 6 : 10;
    dz_nutcut = -screw_length + 3;   
    pin_offset = 1.3;
    function dx_pin(dx) = dx > 0 ? dx - pin_offset: dx + pin_offset;    
    module dupont_connectors(as_clearance = false)  {
        dz = limit_switch.z/2 + prong.z - dz_nutcut;
        dy = limit_switch.y/2; 
        for (dx = rls_dx_prongs()) {
            translate([dx_pin(dx), dy, dz]) 
                dupont_connector(
                    wire_color="red", 
                    housing_color="black",         
                    center=RIGHT,
                    housing=DUPONT_STD_HOUSING(),
                    has_pin=true);              
        }     
    }

    module connection_screws(as_clearance=false) {
  
        screw_name = str("M2x", screw_length);
        dz =limit_switch.z/2 + prong.z + screw_length;  //  mounting_plate(thickness).z + mounting_plate_translation().z ;
        
        module one_screw(pin_offset) {
            translate([0, 0, dz]) {  // mounting_plate_translation
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
                            if (use_dupont_connectors) {
                               translate([0, pin_offset, -0.1]) rod(d=1.2, l=a_lot, $fn=12);
                            }
                        }
                    } else {
                        color(STAINLESS_STEEL) {
                            translate([0, 0, -0.]) screw(screw_name, $fn=12);
                            translate([0, 0, dz_nutcut-0.4]) nut("M2", $fn=12);
                            if (!use_dupont_connectors) {
                                translate([0, 0, 1.8]) nut("M2", $fn=12);
                                translate([0, 0, 1.8 + 1.6 + 0.5]) nut("M2", $fn=12);
                            }
                        }
                        
                    } 
                }
            }
        }
        for (dx = rls_dx_prongs()) {
            translate([dx, 0, 0]) one_screw(pin_offset = dx > 0 ? -pin_offset: pin_offset);
        }      
    }  
    
    module mounting_plate_blank() {
        plate = mounting_plate(thickness);
        translate(mounting_plate_translation()) block(plate,  center=ABOVE+RIGHT);
        if (adjustment_rails) {            
            hull() {
                    translate([0, limit_switch.y/2, mounting_plate_translation().z]) {
                        block([plate.x + 2, 0.1, plate.z], center=ABOVE+RIGHT);
                        block([plate.x, 1, plate.z], center=ABOVE+RIGHT);
                }
            }     
        }       
    }   
   
    module prong_guides() {
        for (dx = rls_dx_prongs()) {
            translate([dx, 0, limit_switch.y+0.5]) {
                center_reflect([1, 0, 0]) translate([0.5, 0, 0]) block([1, limit_switch.y, prong.z], center=ABOVE+FRONT);
            }
        }            
    }
    
    module terminal_probe_spots() {
        // Move off y plane becasue the terminals have holes right on the center line 
        // so the probes weren't making contact!
        translate([0, 1, 8.5]) rod(d= 2, l=a_lot);
    }   
   
   module terminal_block_blank() {
        terminal_block_translation = [
            0, 
            limit_switch.y/2 + thickness, 
            limit_switch.z/2 + prong.z
        ];       
       translate(terminal_block_translation) block(terminal_block, center=ABOVE+LEFT);
   } 
    module shape() {

        render(convexity=10) difference() {
            union() {
                mounting_plate_blank();
                terminal_block_blank() ;
                prong_guides();
            }
            roller_limit_switch_mounting_screws(as_clearance = true, recess = recess_mounting_screws, base_plate_thickness = thickness);
            connection_screws(as_clearance = true);
            if (use_dupont_connectors) {
                dupont_connectors(as_clearance = true);
                 terminal_probe_spots();
            }
            if (trim_support) {
                // Remove parts of the base and holder that may not be needed for printing.  
                // - area behind Dupont connectors
                translate([0, 0, 22]) rotate([-45, 0, 0]) block([100, 100, 100], center =ABOVE);
                translate([0, 0, -7]) rotate([45, 0, 0]) block([100, 100, 100], center =BELOW);
            }
        }      
    }
    module right_handed_part() {
        if (show_vitamins  && !mode_is_printing(mode)) {
            roller_limit_switch(roller_arm_length=roller_arm_length, switch_depressed=switch_depressed);   
            roller_limit_switch_mounting_screws(base_plate_thickness = thickness, recess = recess_mounting_screws);
            connection_screws();
            if (use_dupont_connectors) {
                dupont_connectors();
            }
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

