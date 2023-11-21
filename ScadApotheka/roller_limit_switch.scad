
include <ScadStoicheia/centerable.scad>
include <ScadApotheka/material_colors.scad>


a_lot = 20 + 0;

switch_depressed = true;
roller_arm_length = 20; // [18 : 0.1: 21]

module end_of_customization() {}
//old_roller_limit_switch();


roller_limit_switch(roller_arm_length=roller_arm_length, switch_depressed=switch_depressed);

translate([20, 0, 0]) roller_limit_switch(as_mounting_clearance=true);

function rls_base() = [20, 6.5, 10.5]; // mm
function rls_prong() = [0.5, 3, 5];
function rls_dx_prongs() = [-8, -0.5, 8];
function rls_mount_hole_translation() = [9.5/2, 0, 3.5];

//limit_switch = [20, 6.41, 10.5];

module old_roller_limit_switch() {
    // Prongs up
    import("Limit Switch - Step.amf");
}

module roller_limit_switch(roller_arm_length=20, switch_depressed=false, as_mounting_clearance = false) {
    base = rls_base();
    translation_mount_holes = rls_mount_hole_translation();
    dx_prongs = rls_dx_prongs();
    arm = [roller_arm_length, 3.4, 0.5];
    arm_tab = [0.5, arm.y, 3];
    roller_mount = [3.5, 0.5, 3.5];
    ay_switch = switch_depressed ? 0 : -11.5;
    
    module mounting_clearance() {
        screw_head = 10;
        center_reflect([1, 0, 0]) translate(translation_mount_holes) {
            //rod(d=2.5, l=a_lot, center=SIDEWISE);
            translate([0, rls_base().y/2+2, 0]) rotate([90, 0, 0]) nutcatch_parallel("M2", clh=10);
            translate([0, -screw_head -rls_base().y/2-2, 0]) rotate([90, 0, 0]) 
                hole_through("M2", $fn=12, cld=0.4, l=20, h=screw_head);
        }
    }
    
    if (as_mounting_clearance) {
        mounting_clearance();
    }  else {
    
        color(BLACK_PLASTIC_1) {
            render(convexity = 10) difference() {
                block(base, center=CENTER);
                translate([0, 0, -base.z/2]) block([base.x, a_lot, 1], center=ABOVE+BEHIND);
                mounting_clearance();
            }
        }
        color(STAINLESS_STEEL) {
            for (dx = dx_prongs) {
                translate([dx, 0, base.z/2]) block(rls_prong(), center=ABOVE);
            }
            
        }
        translation_roller = [
            -arm.x + roller_mount.x/2, 
            0, 
            -roller_mount.z
        ];
        d_contact = 2.0;
        dz_contact = switch_depressed ? d_contact/2 : 0;
        translate([base.z - 2, 0, -base.z/2 - 0.5]) {
            rotate([0, ay_switch, 0]) {
                color(STAINLESS_STEEL) {
                    union() {
                        block(arm, center=BEHIND+BELOW);
                        block(arm_tab, center = BEHIND+ABOVE);
                    }
                    center_reflect([0, 1, 0]) translate([-arm.x, arm.y/2, 0]) {
                        block(roller_mount, center=FRONT+BELOW);
                        translate([roller_mount.x/2, 0, -roller_mount.z]) rod(d=roller_mount.x, l=0.5, center=SIDEWISE);
                    }
                }
                
                color("red") translate(translation_roller) rod(d=4.5, l=3.1, center=SIDEWISE);
                
            }
            color("red") translate([-5, 0, dz_contact]) rod(d=d_contact, l=3.1, center=SIDEWISE);
        }
    }
}
