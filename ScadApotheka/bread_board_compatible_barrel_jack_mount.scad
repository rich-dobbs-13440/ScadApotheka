/*

Usage:

use <ScadApotheka/bread_board_compatible_barrel_jack_mount.scad>

bread_board_compatible_barrel_jack_mount();
*/

include <ScadStoicheia/centerable.scad>
include <ScadApotheka/material_colors.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>

a_lot = 100 + 0.0;

/* [Show] */

show_vitamins = true;

/* [Design] */


body = [8.9, 8.89, 6.3];
face = [3.34, 8.81, 10.65];
d_barrel_clearance = 6.88;
d_plug_clearance = 9.5;
d_pin = 2.5;
x_back = 2.9;
breadboard_fragment = [20,15.8,8.42];


module end_customization() {}

bread_board_compatible_barrel_jack_mount(show_vitamins=show_vitamins);


module barrel_jack(as_clearance = false) {
    module blank() {
        block(face, center=FRONT);
    }
    
    module shape() {
         
        color("black") {
            difference() {
                union() {
                    translate([0, 0, -body.z]) block(face, center=FRONT+ABOVE);
                    hull() {
                        rod(d=body.y, l=body.x, center=BEHIND);
                        block(body, center=BEHIND+BELOW);
                    }
                }
                rod(d = d_barrel_clearance, l = a_lot);
            }
            translate([-body.x, 0, 0]) {
                rod(d=body.y, l=x_back, center=BEHIND);
                block([x_back, body.y, body.z], center=BEHIND+BELOW);   
            }
        }
        color(CHROME) {
            rod(d = d_pin, l = body.y, center=BEHIND);
            sphere(d = d_pin, $fn=12);
        }
    }
    if (as_clearance) {
        hull() shape();
    } else {
        shape();
    }
}

module breadboard_fragment() {
    translate([-2, 0, -body.z]) {
        color("red") {
            block(breadboard_fragment, center=BELOW+BEHIND);
        }
    }
}

module bread_board_compatible_barrel_jack_mount(show_vitamins=true) {
    module shape() {
        // The face plate provides strain relief during plug removal
        render(convexity = 10) difference() {
            block([1+face.x, 14+face.y, 2*body.z], center=FRONT);
            rod(d = d_plug_clearance, l=a_lot);
            barrel_jack(as_clearance = true); 
            center_reflect([0, 1, 0]) translate([10, 9, 0]) rotate([0, 90, 0]) hole_through("M2", $fn=12);
        }
        // The backer clip, provides strain relief during plug insertion
        render(convexity = 10) difference() {
            block([12.5, 4+face.y, 2*body.z], center=BEHIND);
            rod(d = body.y, l=10.5+0.5, center=BEHIND);
            block([10.5+0.5, body.y +1, a_lot], center=BEHIND+BELOW);
            translate([-3, -4, 0]) block([10, 20, 30], center=LEFT+BEHIND);
            translate([-4, -2., 0]) rotate([46, 0, 0]) block([10, 20, 30], center=LEFT+BEHIND);
        }
        
        
        // The breadboard clip holds the breadboard 
        dy_clip = 30;
        translate([1 + face.x, dy_clip, -body.z-breadboard_fragment.z]){ 
            block([10, 2, body.z+breadboard_fragment.z + body.y/2 + 2], center=ABOVE+LEFT+BEHIND);
            block([10, breadboard_fragment.y + 2, 2], center=BELOW+LEFT+BEHIND);
        }
        translate([1 + face.x, dy_clip, body.y/2+2]) 
            block([10, breadboard_fragment.y + 2, 2], center=ABOVE+LEFT+BEHIND);
    }
    if (show_vitamins) {
        barrel_jack();
        breadboard_fragment();
    }
    shape();
}


