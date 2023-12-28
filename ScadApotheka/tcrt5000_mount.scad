/* 

The TCRT5000 is an inexpensive reflective photosensor that operates
using infrared light.  

Usage:
    use  <ScadApotheka/tcrt5000_mount.scad>
    
    tcrt5000_reflective_optical_sensor_holder(
        show_body = true,
        show_rails = true,
        orient_for_printing = false,
        orient_for_mounting = false | RIGHT | LEFT | FRONT | BEHIND,         
        show_vitamins = true,
        x_padding = x_padding, 
        y_padding = y_padding, 
        z_above = z_above);
        
     
This mount is designed to incorporate it into an assembly
consisting of 3d parts.  The main advantage of this mount, 
as compared to commercially available breakout boards
for this component is its compact size, with the mounting 
resistors and leads below sensor component.  It also
provides a locking mechanism for the Dupont jumpers.

Its disadvantage is that it requires assembly that is 
somewhat finicky, and requires precision installation
of tiny M2 screws and nuts.  Also, this setup uses
fixed values for resistors, so it might require 
more work on getting a proper reflective pattern for
to detector.
 
For use with 3.3VDC GPIO pins and supply voltage, the  values of 
resistors needed are:
    Component      Bulb     Resistor Value     Resistor Banding 
    IR LED              blue            33Ω               Orange Orange  Black   Gold
    IR Photodiode   black          8.2kΩ            Gray      Red       Red     Gold
    
TODO:  Calculate resistors needed for use with an Arduino and 5VDC.  


Assembly, 
*/

include <ScadStoicheia/centerable.scad>
use <ScadStoicheia/visualization.scad>
include <ScadApotheka/material_colors.scad>
use <ScadApotheka/dupont_pins.scad>

a_lot = 100 + 0;

/* [Sensor Dimensions] */
    sensor_body = [10, 5.4, 3.7];
    y_body_front = 2.5;
    sensor_body_chamfer = [0.5, 1, 0.5];
    d_registration_pin = 0.8;
    h_registration_pin = 2.9;
    shield = [0.3, 3.2, 6];
    prong = [0.8, 0.6, 3.9];
    prong_tip = [0.8, 0.7, 1];
    d_led = 2.8;
    dx_led = 2.1;
    dz_led = 1;
    dx_lead = 2.75;
    dy_lead = 2.54/2;
    d_lead = 0.4;
    h_lead = 13.5;


/* [Ouput Control] */
    show_vitamins = true;
    show_rails = true;
    show_body = true;    
    show_holder = true;
    show_nuts = true;
    show_screws = true;
    show_pins = true;
    orient_for_printing = false;

    show_cross_section = false;
    dy_cross_section = 0; // [-20 : 0.1 : 20]

/* [Sensor Holder Design] */
    x_padding = 1;
    y_padding = 1;
    z_above = 0.5;
    x_wall = 5;
    y_wall = 2;
    cl_wall = 0.5;
    cl_d_lead = 0.5;

    
    cl_prong_tip = 0.6;
    cl_d_registration_pin = 0.5;
    cl_x_prong = 0.25;
    
/* [Wire Design] */
    positive_lead_screw = "M2x6";
    lead_screw = "M2x6";

    ay_center = -15;
    ay_spread = 17;
    dx_resistor_nuts = 5.5;
 // Tuning of resistor lead geometry for the sensor 
    dx_resistor_lead_sensor = -8;
    ay_resistor_lead_sensor    = -15;
    dz_pinch_resistor_lead_sensor = -2;
    dx_sensor_resistor = -10;
    dy_sensor_resistor = 0.5;
    az_sensor_resistor = -17;
 // Tuning of LED resistor geometry for the LED
    dx_resistor_lead_led = 9;
    ay_resistor_lead_led = 26;
    dz_pinch_resistor_lead_led = -3;
    h_resistor_lead_led = 15;
    dx_led_resistor = -6;
    dy_led_resistor = -3.5;
    az_led_resistor = 13;    
// Tuning of  negative lead geometry  
    dx_negative_nut = -6;
    
    x_connection_blank = 16;
    y_connection_blank = 12;
    z_connection_blank = 16;
    dx_connection_blank = -1;
    dy_connection_blank = 1;
    dz_connection_blank = 0;
    cl_connection_d_lead = 0.6;
    
    d_lead_entry = 2;
    dy_dupont_pin = 4.5;
    h_resistor_lead = 20;
    
    cl_d_resistor_lead = 1;

/* [Rail Design] */
    cl_dy_rails = 0.5;
    cl_dx_clip_tip = 0.5;
    dx_clip_tip_overlap = 1;
    
/* [Build Plate Layout] */
    x_body_bp = -5;
    y_body_bp = 10;

module end_of_customization() {}


module resistor(bands, h_leds=[2, 2], as_clearance = false) {
    d_band = 1.8;
    h = 6.5;
    h_band = 0.7;
    dz = 1.1;
    d_lead_w_cl = d_lead + (as_clearance ? cl_d_resistor_lead : 0);
    d_resistor = d_band  + (as_clearance ? 0.5 : -0.1);
    color(CHROME) {
        can(d=d_lead_w_cl, h = h_leds[0], center=BELOW, $fn=12);
        can(d=d_lead_w_cl, h = h + h_leds[1], center=ABOVE, $fn=12);
    }
    
    color("tan") hull() {
        translate([0, 0, d_resistor/2]) sphere(d = d_resistor, $fn=20);
        translate([0, 0, h - d_resistor]) sphere(d = d_resistor, $fn=20);  
    }
    for (i = [0: len(bands) - 1]) {
        color(bands[i]) 
            translate([0, 0,  1.2 + i*dz]) 
                can(d = d_band, h = h_band);
    }
}



module tcrt5000_default_lead(as_clearance) {
     if (as_clearance) {
        translate([0, 0 , 2]) can(d=d_lead + cl_d_lead, h=h_lead + 4, center=BELOW, $fn=12);                                  
     } else {
        color(CHROME) can(d=d_lead, h=h_lead, center=BELOW, $fn=12);  
     }      
}


module tcrt5000_reflective_optical_sensor(as_clearance = false, h_lead = h_lead, lead_rotations=[]) {
    // Order leads counter C(sensor)  A C(led) E 
    lead_translations = [
        [-dx_lead, dy_lead, 0], 
        [dx_lead, dy_lead, 0], 
        [dx_lead, -dy_lead, 0], 
        [-dx_lead, -dy_lead, 0],
    ];
    module prongs() {
        center_reflect([0, 1, 0]) translate([0, sensor_body.y/2, 0]) {
            block(prong, center=BELOW+LEFT);
            hull() {
                translate([0, 0, -prong.z]) 
                    block([prong.x, prong.y, prong_tip.z], center=ABOVE+LEFT);
                translate([0, 0, -prong.z+prong_tip.z]) 
                    block([prong_tip.x, prong_tip.y, 0.01], center=ABOVE+RIGHT);
            }
        }
    }

    module shape(child_count) {
        chamfer = sensor_body_chamfer;
        color(BLACK_PLASTIC_1) {
            cl_walls = as_clearance ? [2 * cl_wall, 2 * cl_wall, 0] : [0, 0, 0];
            dy_front = (sensor_body.y - y_body_front)/2;
            hull() {
                block([sensor_body.x, y_body_front, sensor_body.z - chamfer.z] + cl_walls, center=ABOVE);
                translate([chamfer.x/2, 0, 0] ) block([sensor_body.x - 2* chamfer.x, y_body_front - chamfer.y, sensor_body.z], center=ABOVE);
                translate([-dy_front/2, 0, 0]) 
                    block([sensor_body.x - dy_front, sensor_body.y, sensor_body.z - chamfer.z] + cl_walls, center=ABOVE);
                    block([sensor_body.x - dy_front - chamfer.x, sensor_body.y - chamfer.y , sensor_body.z], center=ABOVE);
            }
            d_pin = d_registration_pin + (as_clearance ? cl_d_registration_pin : 0);
            translate([-sensor_body.x/2, -sensor_body.y/2, 0]) can(d=d_pin, h=h_registration_pin, center=FRONT+RIGHT+BELOW);
            block(shield, center=ABOVE);
            prongs();
            if (as_clearance) {
                prong_cavity = [prong.x + 2 * cl_x_prong, sensor_body.y, prong.z + 2];
                block(prong_cavity);
            }
        }
        color(BLUE_LED) {
            translate([dx_led, 0, sensor_body.z+dz_led]) {
                sphere(d=d_led, $fn=30);
                can(d=d_led, h=2, center=BELOW);
            }
        }
        color(IR_LED) {
            translate([- dx_led, 0, sensor_body.z+dz_led]) {
                sphere(d=d_led, $fn=30);
                can(d=d_led, h=2, center=BELOW);
            }
        } 
        // Leads
        for (i = [0:1:3]) {
            translate(lead_translations[i]) {
                rotation = is_undef(lead_rotations[i]) ? [0, 0, 0] : lead_rotations[i];
                rotate(rotation) {
                     //echo("child_count", child_count);
                     if (i < child_count) {
                         children(i) tcrt5000_default_lead(as_clearance);
                     } else {      
                        tcrt5000_default_lead(as_clearance);                             
                     }
                 }
             }
         }

    }
    shape(child_count = $children) {
        if ($children > 0) {
            children(0);
        }
        if ($children > 1) {
            children(1);
        }
        if ($children > 2) {
            children(2);
        }
        if ($children > 3) {
            children(3);
        }
    };  
}


module tcrt5000_lead_cavity(h_lead, dz_pinch) {
   pairwise_hull() {
       sphere(d=d_lead_entry); 
       translate([0, 0, dz_pinch]) sphere(d=d_lead + cl_connection_d_lead); 
       translate([0, 0, -h_lead]) sphere(d=d_lead_entry); 
   }
}


module tcrt5000_negate_lead_screw(as_clearance = true, show_nut = true, show_screw = true, show_pin) {
    dy_nut = 0.35;
    dz_nut = -6;
    dy_lead_negative_lead = -2;
    h_screw_access = 10;
    dz_lead_screw = 2;
    // Negative lead nut - attached to resistors
    translate([dx_negative_nut, -dy_lead_negative_lead  + dy_nut, dz_nut]) {
        rotate([-90, 0, 0]) {
            if (as_clearance) {
                //rotate([0, 0, -90]) nutcatch_sidecut(name   = "M2",  clh    =  0.5,  clk    =  clk);
                nutcatch_parallel(name   = "M2",  clh    =  10,  clk    =  0.5);  
                translate([0, 0, h_screw_access + dz_lead_screw]) 
                    hole_through("M2", $fn=12, h = h_screw_access);
            } else if (show_nut) {
                nut("M2");
            }
        }
    }
    // Negative dupont connection
    translate([dx_negative_nut + 0.8, dy_dupont_pin, -11]) {
            dupont_connector(
            wire_color = "black", 
            housing_color = "black",         
            center = BELOW,
            has_pin = true, 
            as_clearance = as_clearance);
    }  
    // Resistor leads to negative nuts
   translate([dx_negative_nut, -dy_lead_negative_lead, 0]) {
       translate([-0.8, 0, 0]) {
            if (as_clearance) {
                tcrt5000_lead_cavity(h_lead = z_connection_blank, dz_pinch = dz_nut); 
            } else {      
               color("YELLOW") { 
                    can(d=d_lead, h = h_lead, center = BELOW, $fn=12); 
                }
           }
       }
       translate([0.8, 0, 0]) {
            if (as_clearance) {
                tcrt5000_lead_cavity(h_lead = z_connection_blank, dz_pinch = dz_nut); 
            } else {
                color("PURPLE") {
                   can(d=d_lead, h = h_lead, center = BELOW, $fn=12); 
               }
           }
       } 
   }
}


module tcrt5000_led_lead_screw(as_clearance = true, show_nut = true, show_screw = true, show_pin=false) {

    dx_nut = 0.35;
    dy_nut = 0.35;    
    dz_nut = -11;    
    tcrt5000_default_lead(as_clearance = as_clearance);
//    // Resistor lead
//    color("PURPLE") {
//        d_lead_w_cl = as_clearance ? d_lead + cl_connection_d_lead : d_lead;
//        translate([0, 2*dy_nut, dz_nut+5]) can(d=d_lead_w_cl, h = h_resistor_lead, center = BELOW, $fn=12); 
//        if (as_clearance) {
//            translate([0, 2*dy_nut, dz_nut]) can(taper=d_lead_w_cl, d = 1.5, h = 6, center = BELOW, $fn=12); 
//        }
//    }
    clk = 0.5;
    dz_lead_screw = 2;
    h_screw_access = 10;    
    translate([dx_nut, dy_nut, dz_nut]) {
        rotate([0, 90, 0]) {
            if (as_clearance) {
                //nutcatch_parallel(name   = "M2",  clh    =  10,  clk    =  0.5);  // clearance aditional to nominal key width
                rotate([0, 0, -90]) nutcatch_sidecut(name   = "M2",  clh    =  0.5,  clk    = 1);
                translate([0, 0, h_screw_access + dz_lead_screw]) hole_through("M2", $fn=12, h = h_screw_access, l=4.5);
                // Resistor lead
            } else {
                if (show_nut) {
                   translate([0, 0, -dx_nut]) nut("M2");
                } 
                if (show_screw) {
                     translate([0, 0, dz_lead_screw]) screw("M2x4", $fn=12);
                }
            }   
        }
    }  
    led_bands = ["orange", "orange",  "black", "gold"];
    translate([0, 2*dy_nut, dz_nut - 3.5]) 
        rotate([180, 0, 0])  
            resistor(bands=led_bands, h_leds=[7, 2], as_clearance=as_clearance);    
}


module tcrt5000_sensor_lead_screw(as_clearance = true, show_nut = true, show_screw = true, show_pin) {
    tcrt5000_default_lead(as_clearance = as_clearance);
    dx_nut = -0.35;    
    dy_nut = 0.35;
    dz_nut  = -11; 
    clk = 1;
    clh = 0.5;
    dz_lead_screw = 4;
    h_screw_access = 10;    
    translate([dx_nut, dy_nut, dz_nut]) {
        rotate([0, -90, 0]) {
            if (as_clearance) {
                //nutcatch_parallel(name   = "M2",  clh    =  clh,  clk    =  clk);  // clearance aditional to nominal key width
                rotate([0, 0, -90]) nutcatch_sidecut(name   = "M2",  clh    =  0.5,  clk    =  clk);
                translate([0, 0, h_screw_access + dz_lead_screw]) hole_through("M2", $fn=12, h = h_screw_access, l=6.5);
            } 
            if (show_nut) {
               translate([0, 0, dx_nut]) nut("M2");
            } 
            if (show_screw) {
                 translate([0, 0, dz_lead_screw]) screw(lead_screw, $fn=12);
            }
            
        }
    }
    // Signal_dupont connection
    translate([-dz_lead_screw, 0, dz_nut -3]) {
        dupont_connector(
            wire_color = "yellow", 
            housing_color = "yellow",         
            center = BELOW,
            has_pin = true, 
            as_clearance = as_clearance);
    } 
//    color("YELLOW") {
//        d_lead_w_cl = as_clearance ? d_lead + cl_connection_d_lead : d_lead;
//        translate([0, 2*dy_nut, dz_nut+5]) can(d=d_lead_w_cl, h = h_resistor_lead, center = BELOW, $fn=12); 
//        if (as_clearance) {
//            translate([0, 2*dy_nut, dz_nut]) can(taper=d_lead_w_cl, d = 1.5, h = 6, center = BELOW, $fn=12); 
//        }
//    }        
    sensor_bands = ["gray", "red",  "red", "gold"];    
    translate([0, 2*dy_nut, dz_nut - 3.5]) 
        rotate([180, 0, 0])  
            resistor(bands=sensor_bands, h_leds=[7, 2], as_clearance=as_clearance);    
//     // Sensor resistor nut
//    dy_nut = .25;
//    clk = 0.5;
//    clh = 10;
//    h_screw_access = 10;
//    translate([-dx_resistor_nuts, -dy_lead  + dy_nut, -5]) {
//        rotate([-90, 0, 0]) {
//            if (as_clearance) {
//                nutcatch_parallel(name   = "M2",  clh    =  clh,  clk    =  clk);  // clearance aditional to nominal key width
//            } else if (show_nuts) {
//                nut("M2");
//            }
//        }
//    }  
//    // Sensor lead and resistor screw
//    translate([-dx_resistor_nuts, dy_dupont_pin, -5]) {
//        rotate([-90, 0, 0]) {
//            if (as_clearance) {
//                 translate([0, 0, h_screw_access]) hole_through("M2", $fn=12, h = h_screw_access);
//            } else if (show_screws) {
//                screw(lead_screw, $fn=12);
//            }
//        }
//    }  
// 
//
//        sensor_bands = ["gray", "red",  "red", "gold"];
//        dz = dz_connection_blank - z_connection_blank;
//
//        translate([dx_sensor_resistor, dy_sensor_resistor, dz]) 
//            rotate([0, 0, az_sensor_resistor])
//                rotate([0, 90, 0]) 
//                    resistor(bands=sensor_bands, h_leds=[1, 0.2], as_clearance=as_clearance);
//    
 
//   
//    d_lead_w_cl = as_clearance ? d_lead + cl_connection_d_lead : d_lead;
//    // First resistor lead
//    translate([dx_resistor_lead_sensor, -dy_lead - d_lead , 0]) {
//        rotate([0, ay_resistor_lead_sensor, 0]) {
//            if (as_clearance) {
//                tcrt5000_lead_cavity(h_lead = z_connection_blank, dz_pinch = dz_pinch_resistor_lead_sensor);
//            } else {
//                color("YELLOW") { 
//                    can(d=d_lead_w_cl, h = h_resistor_lead, center = BELOW, $fn=12);
//                }
//            }
//        }
//    }    
    
//        color("yellow") {
//            label("s", dx=-5.5, dy=2.5, size=4);
//        }    
    
//        color("yellow") {
//            label("8.2kΩ", dx=-13, dy=-2.5, size=1.6);
//        }        
}


module tcrt5000_positive_lead_screw(as_clearance = true, show_nuts = true, show_screws = true) {
    h_screw_access = 10;
    clh = 10;
    clk = 0.5;
    dy_nut = .25;
    dz_dupont_screw = 5;
    dz_positive_lead = -6.;
    
    color(BLACK_IRON) {
        // Positive lead nut
        translate([0, dy_lead + dy_nut, dz_positive_lead]) {
            rotate([-90, 0, 0]) {
                if (as_clearance) {
                    nutcatch_parallel(name   = "M2",  clh    =  clh,  clk    =  clk);  // clearance aditional to nominal key width
                } else if (show_nuts) {
                    nut("M2");
                }
            }
        }
        // Positive lead screw
        translate([0, dy_dupont_pin, dz_positive_lead]) {
            rotate([-90, 0, 0]) {
                if (as_clearance) {
                     translate([0, 0, h_screw_access]) hole_through("M2", $fn=12, h = h_screw_access);
                } else if (show_screws) {
                    screw(positive_lead_screw, $fn=12);
                }
            }
        }
    }
    // Positive dupont connection
    translate([0.8, dy_dupont_pin, -11]) {
            dupont_connector(
            wire_color = "red", 
            housing_color = "red",         
            center = BELOW,
            has_pin = true, 
            as_clearance = as_clearance);
    }
}

module tcrt5000_reflective_optical_sensor_holder(
    show_body = true,
    show_rails = true,
    orient_for_printing = false,
    orient_for_mounting = false, 
    show_vitamins = true,
    mouse_ears = false,
    x_padding = x_padding, 
    y_padding = y_padding, 
    z_above = z_above
    ) {
   top_blank = [sensor_body.x + 2 * x_padding, sensor_body.y + 2 * y_padding, z_above];
    ax_led = -0;
    ax_sensor = -0;
   lead_rotations = [
        [0, ay_center, 0],
        [0, -ay_center, 0],
        [ax_led, 0, 0],
        [ax_sensor, 0, 0]
    ];
        
   module blank() {
       block(top_blank, center=ABOVE);
   } 
   module connection_blank() {
       connection_blank = [x_connection_blank, y_connection_blank, z_connection_blank];
        translate([dx_connection_blank, dy_connection_blank, dz_connection_blank]) block(connection_blank, center=BELOW);
   }
   module prong_cavity() {
       z_below = prong.z - prong_tip.z - cl_prong_tip;
       translate([0, 0, -z_below]) block([2, a_lot, 2], center=BELOW);
   }
   
   module clip_rails(as_clearance = true) {
    dz_rails = -3;
    x_strap = 1;
    dy_rails = y_connection_blank/2  + (as_clearance ? 0 : cl_dy_rails); 
    y_strap = y_connection_blank +  2 * cl_dy_rails;
    dx_to_base = dx_connection_blank + x_connection_blank/2 + x_strap;
    x_clip_tip = 2;
//       dj_clip_tip = j_strap + x_connection_blank + cl_dx_clip_tip;
    x_rail = x_connection_blank + x_strap + cl_dx_clip_tip + x_clip_tip;
//       dx_latch = -cl_dx_rails - dx_clip_tip_overlap;
//       latch_support = [dx_clip_tip_overlap + cl_dx_rails, 1, abs(dz_rails)];
    color(PART_2, alpha=1) {
        translate([dx_to_base, dy_connection_blank, 0]) {
            center_reflect([0, 1, 0]) translate([0, dy_rails, dz_rails]) {
                rotate([45, 0, 0]) block([x_rail, 2, 2], center=BEHIND);
                    if (!as_clearance) {
//                       // Add clip tip
//                       translate([dj_clip_tip, 0, 0]) {
//                           hull() {
//                                translate([dx_latch, 0, 0]) rotate([0, 45, 0]) 
//                                    block([2, 1, 2], center=RIGHT);
//                                rotate([45, 0, 0]) block([2, j_clip_tip, 2], center=RIGHT);
//                           }
//                           translate([dx_latch, 0, 0]) {
//                               block(latch_support, center = FRONT+RIGHT+ABOVE);
//                               if (mouse_ears) {
//                                   translate([2, 0, -dz_rails]) can(d=5, h=0.2, center = BELOW);
//                               }
//                           }
//                      }
//                       // Printing support
//                       translate([0, 0, 0]) block([j_rail, sqrt(2), abs(dz_rails)], center=FRONT+RIGHT + ABOVE);
                        } 
                    }
                block([x_strap, y_strap, 3], center=BEHIND+BELOW);
            }
        }
   }
   
    module label(label, dx, dy, size) {
        skew_x = 0.7;  // Horizontal skew amount
        skew_y = 0.0;  // Vertical skew amount
        
        skew_matrix = [
            [1, 0, skew_x, 0],
            [0, 1, skew_y, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        ];    
        translate([dx, dy, dz_connection_blank - z_connection_blank]) {
            rotate([180, 0, 0]) {
                multmatrix(skew_matrix) {
                    linear_extrude(height = 0.7) {
                        text(label, size = size);
                    }
                }
            }
        }        
    }
    


    module shape() {
        color(PART_1, alpha=1) {
            difference() {
                union() {
                    blank();
                    connection_blank();
                }
                tcrt5000_reflective_optical_sensor(as_clearance=true, lead_rotations = lead_rotations) {
                    tcrt5000_default_lead(as_clearance = true);
                    tcrt5000_default_lead(as_clearance = true);
                    tcrt5000_led_lead_screw(as_clearance = true);
                    tcrt5000_sensor_lead_screw(as_clearance = true);
                    
//                    tcrt5000_lead_cavity(h_lead = h_lead, dz_pinch = -6);
//                    tcrt5000_lead_cavity(h_lead = h_lead, dz_pinch = -6);
                }
                tcrt5000_positive_lead_screw(as_clearance = true);
                prong_cavity(); 
                clip_rails(as_clearance = true);
                 tcrt5000_negate_lead_screw(as_clearance = true);
                if (show_cross_section) {
                    translate([0, dy_cross_section, 0]) plane_clearance(RIGHT); 
                }
            }
        }
//        color("black") {
//            label("-", dx=-12, dy=4.5, size=7);
//        }

//        color("red") {
//            label("+", dx=3, dy=7, size=5);
//        }   

       
    }
    
    if (orient_for_printing) {
        if (show_body) { 
            z_for_printing = x_connection_blank/2 - dx_connection_blank;
            translate([x_body_bp, y_body_bp, z_for_printing]) 
            rotate([0, -90, 0]) shape();
        }
        if (show_rails) {
            rotate([0, 180, 0]) clip_rails(as_clearance = false);
        }
    } else {
        dy_to_mount = y_connection_blank/2 - dy_connection_blank;
        translation = 
            orient_for_mounting == FRONT ? [dy_to_mount, 0, 0] : 
            orient_for_mounting == BEHIND ? [-dy_to_mount, 0, 0] : 
            orient_for_mounting == LEFT ? [0, dy_to_mount, 0] : 
            orient_for_mounting == RIGHT ? [0, -dy_to_mount, 0] : 
            [0, 0, 0];
        rotation = 
            orient_for_mounting == FRONT ? [0, 0, -90] : 
            orient_for_mounting == BEHIND ? [0, 0, 90] : 
            orient_for_mounting == LEFT ? [0, 0, 0] : 
            orient_for_mounting == RIGHT ? [0, 0, 180] :
            [0, 0, 0] ;
        translate(translation) rotate(rotation) {
            if (show_vitamins) {
                tcrt5000_positive_lead_screw(as_clearance = false, show_nuts = show_nuts, show_screws = show_screws);
                tcrt5000_reflective_optical_sensor(lead_rotations = lead_rotations) {
                    tcrt5000_default_lead();
                    tcrt5000_default_lead();
                    tcrt5000_led_lead_screw(as_clearance = false);
                    tcrt5000_sensor_lead_screw(as_clearance = false);
                }
                tcrt5000_negate_lead_screw(as_clearance = false, show_nut = show_nuts, show_screw = show_screws, show_pin = show_pins);
            }
            if (show_body) {      
                shape();
            }
            if (show_rails) {
                clip_rails(as_clearance = false);
            }
        }
    }
}

if (show_holder) {
    tcrt5000_reflective_optical_sensor_holder(
        show_body = show_body,
        show_rails = show_rails,  
        show_vitamins = show_vitamins,
        orient_for_mounting = CENTER,
        mouse_ears = true,
        orient_for_printing = orient_for_printing);
}



