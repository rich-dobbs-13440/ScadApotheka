/* 

Usage:
    use <ScadApotheka/m2_helper.scad>
    
*/

include <nutsnbolts-master/cyl_head_bolt.scad>
include <nutsnbolts-master/data-metric_cyl_head_bolts.scad>
include <ScadStoicheia/centerable.scad>
include <ScadApotheka/material_colors.scad>

/* [Examples] */

show_nutcatch_side = false;
show_screw_with_side_cut = false;
show_custom_screw = true;

screw_length = 16; //[4, 6, 8, 10, 12, 16, 20] 
nut_tightness = 0; // [0 : 0.5 : 20]

head = "BELOW"; // [BELOW, ABOVE]
head_is = 
    head == "BELOW" ? BELOW :
    head == "ABOVE" ? ABOVE : 
    assert(false);


nut_catch = "FRONT"; // [FRONT, ABOVE, BELOW, bore]
nut_catch_direction = 
    nut_catch == "FRONT" ? FRONT :
    nut_catch == "ABOVE" ? ABOVE :  
    nut_catch == "BELOW" ? BELOW :  
    nut_catch == "bore" ? "bore" : 
    assert(false);

a_lot = 100;

end_of_customization() {}

module tuned_M2_nutcatch_side_cut(as_clearance = true, dx=1.5, slot_clh=0.5, slot_clk=0.5) {
    
    if (as_clearance) {
        translate([0, 0, 0.125]) nutcatch_sidecut("M2", clh=0.25, $fn = 12);
        hull() {
            translate([dx, 0, 0.125]) nutcatch_sidecut("M2", clh=0.25, $fn = 12);
//            // For easier insertion we'll provide some guidance
            translate([dx+3, 0, 0.125 + slot_clh/2])  nutcatch_sidecut("M2", $fn = 12, clh=slot_clh, clk=slot_clk);
        }
    } else {
        translate([0, 0, 0]) color(STAINLESS_STEEL) nut("M2");
    }
}

if (show_nutcatch_side) {
    tuned_M2_nutcatch_side_cut(as_clearance=false);
    color("red", alpha=0.25) tuned_M2_nutcatch_side_cut(as_clearance=true);
}

if (show_custom_screw) {
    m2_screw(screw_length, head_is=head_is, nut_tightness=nut_tightness, as_clearance=false, nut_catch=nut_catch_direction);
    color("red", alpha=0.25) m2_screw(screw_length, head_is=head_is, nut_tightness=nut_tightness, as_clearance=true, nut_catch=nut_catch_direction);
}

module m2_screw(
        length, 
        nut_tightness = 0, 
        head_is = ABOVE, 
        as_clearance = false,
        nut_catch = "bore",
        screw_color = BLACK_IRON, 
        nut_color=STAINLESS_STEEL) {
    cld = nut_catch == "bore" ? 0.2 : 0.4;
    screw_name = str("M2x", length);
    rotation = 
        head_is == ABOVE ? [0, 0, 0] :            
        head_is == BELOW ? [180, 0, 0] :
        assert(false);
            
    dz_nut = -length+2+nut_tightness;
            
    module tapered_parallel_nutcatch() {
        translate([0, 0, -length+2+nut_tightness]) nutcatch_parallel("M2", clh = a_lot, clk =  0.0);
        hull() {
            translate([0, 0, dz_nut-2]) nutcatch_parallel("M2", clh = 2, clk =  0.0);
            translate([0, 0, dz_nut-4]) nutcatch_parallel("M2", clh = a_lot, clk=0.4);
        }        
    }
    if (as_clearance) {
        h = a_lot;
        rotate(rotation) translate([0, 0, h]) hole_through("M2", cld=cld,  h=h, $fn=12);  // Translate upward for better differencing.
        if (nut_catch == BELOW) {
            if (head_is == ABOVE) {
                rotate(rotation) tapered_parallel_nutcatch();
            }
        } else if (nut_catch == ABOVE) {
            if (head_is == BELOW) {
                rotate(rotation) tapered_parallel_nutcatch();
            } 
         } else if (nut_catch == FRONT) {
            if (head_is == ABOVE) {
                translate([0, 0, dz_nut]) tuned_M2_nutcatch_side_cut(as_clearance = true);
            } else if (head_is == BELOW) {
                rotate(rotation) translate([0, 0, dz_nut]) tuned_M2_nutcatch_side_cut(as_clearance = true);
            }
        }
    } else {
        rotate(rotation) {
            color(screw_color) screw(screw_name, $fn=12);
            if (nut_catch != "bore") {
                translate([0, 0, dz_nut]) color(nut_color) nut("M2");}
        }
    }
}

if (show_screw_with_side_cut) {
    m2_screw(20, head_is=ABOVE, nut_tightness=nut_tightness, as_clearance=false, nut_catch=FRONT);
    color("red", 0.25) m2_screw(20, head_is=ABOVE, nut_tightness=nut_tightness, as_clearance=true, nut_catch=FRONT);
}
