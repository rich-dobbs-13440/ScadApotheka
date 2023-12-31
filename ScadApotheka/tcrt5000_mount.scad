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
    h_lead = 15.5;


/* [Ouput Control] */
    show_vitamins = true;
    show_rails = true;
    show_body = true;    
    show_holder = true;
    show_nuts = true;
    show_screws = true;
    show_pins = true;
    orient_for_printing = false;
    orient_for_mounting = "CENTER"; // [CENTER, FRONT, BEHIND, RIGHT, LEFT]
    
    function orient_for_mounting(a) = 
        a  == "CENTER" ? CENTER:
        a  == "FRONT" ? FRONT:
        a  == "BEHIND" ? BEHIND:
        a  == "RIGHT" ? RIGHT:
        a  == "LEFT" ? LEFT:
        assert(false); 

    show_cross_section = false;
    dy_cross_section = 0; // [-8 : 0.1 : 15]
    dx_cross_section = 0; // [-15 : 0.1 : 15]
    
/* [Housing Design] */
    x_connection_blank = 19;
    y_connection_blank = 14;
    z_connection_blank = 24;
    dx_connection_blank = -2.5;
    dy_connection_blank = 2;
    dz_connection_blank = 0.25;
   

/* [Sensor Holder Design] */
    x_padding = 1;
    y_padding = 1;
    z_above = 0.5;
    x_wall = 5;
    y_wall = 2;
    cl_wall = 0.5;
    cl_d_lead = 1;

    
    cl_prong_tip = 0.6;
    cl_d_registration_pin = 0.5;
    cl_x_prong = 0.25;
    
/* [Lead Bending Design] */
    ax_sensor_p = 4;
    ay_sensor_p = -10;
    ax_led_p = 4;
    ay_led_p = 10;
    ax_led_n = -4;
    ay_led_n =-10;
    ax_sensor_n = -4;
    ay_sensor_n = 10;

    ay_spread = 17;   
   
   lead_rotations = [
        [ax_sensor_p, ay_sensor_p, 0],
        [ax_led_p, ay_led_p, 0],
        [ax_led_n, ay_led_n, 0],
        [ax_sensor_n, ay_sensor_n, 0]
    ];   
    
/* [Wire Design] */
    //side_offset_dupont_pin = 0.35;
    side_offset_dupont_pin = 0.8;
    side_offset_resistor_lead = 0.8;  
    nut_tightness_offset = 0.35;
    cl_connection_d_lead = 0.6; 
    
    dx_resistor_nuts = 5.5;
 // Tuning of resistor lead geometry for the sensor
    dx_sensor_nut = -0.35;  // Relative to the lead   
    dy_sensor_nut = 0.8;  // Relative to the lead 
    dz_sensor_nut  = -11.5; 
    vertical_offset_dupont_pin_sensor  = -4;

 // Tuning of LED resistor geometry for the LED
    dx_led_nut = 0.35;
    dy_led_nut = 0.8;    
    dz_led_nut = -11.5;     
    dx_resistor_lead_led = 9;
    ay_resistor_lead_led = 26;
    dz_pinch_resistor_lead_led = -3;
    h_resistor_lead_led = 15;
    dx_led_resistor = -6;
    dy_led_resistor = -3.5;
    az_led_resistor = 13;    
// Tuning of  negative lead geometry  
    dx_negative_nut = 3.5;
    dy_negative_nut = 3.;
    dz_negative_nut = -18;
    
    // Make the offset as small as possible, since this is the lowest lead
    vertical_offset_dupont_pin_n = -3.5; 
 // Tuning of  positive lead geometry large as possible for strength  
    vertical_offset_dupont_pin_p = -5;
    screw_hole_thickness_p = 3.75;
    dx_positive_nut  = 0;
    dy_positive_nut = 2;
    dz_positive_nut = -7;
  

    
    d_lead_entry = 2;

    h_resistor_lead = 20;
    
    cl_d_resistor_lead = 1;
    cl_d_resistor_body = 1;
    dz_resistor = -16;

/* [Rail Design] */
    cl_dy_rails = 0.5; // [0.5:normal, 5:test]
    cl_dx_clip_tip = 0.5;
    dy_clip_tip_overlap = 1;
    
/* [Build Plate Layout] */
    x_body_bp = 20;
    y_body_bp = 10;

module end_of_customization() {}


module rotate_yaw_pitch_and_roll(yaw, pitch, roll) {
    rotate([0, 0, yaw])   // Yaw rotation around Z-axis
    rotate([pitch, 0, 0]) // Pitch rotation around X-axis
    rotate([0, roll, 0])  // Roll rotation around Y-axis
    children();
}



module resistor(bands, h_leds=[20, 20], cl_h_led = 1, as_clearance = false) {
    d_band = 1.8;
    h = 6.5;
    h_band = 0.7;
    dz = 1.1;
    
    d_lead_w_cl = d_lead + (as_clearance ? cl_d_resistor_lead : 0);
    d_resistor = d_band  + (as_clearance ? cl_d_resistor_body : -0.1);
    color(CHROME) {
        h_cl = as_clearance ?  cl_h_led : 0;
        can(d=d_lead_w_cl, h = h_leds[0] + h_cl, center=BELOW, $fn=12);
        can(d=d_lead_w_cl, h = h + h_leds[1] + h_cl, center=ABOVE, $fn=12);
    }
    if (as_clearance) {
        hull() {
            translate([0, 0, d_resistor/2]) sphere(d = d_resistor, $fn=20);
            translate([0, 0, h - d_band]) sphere(d = d_resistor, $fn=20); 
        }
    } else {
        color("tan") hull() {
            translate([0, 0, d_resistor/2]) sphere(d = d_resistor, $fn=20);
            translate([0, 0, h - d_resistor]) sphere(d = d_resistor, $fn=20);  
        }
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
    module prongs(as_clearance = false) {
        center_reflect([0, 1, 0]) translate([0, sensor_body.y/2, 0]) {
            if (as_clearance) {
                block(prong + [1, 1, 1], center=BELOW + LEFT);
                translate([0, 0, -prong.z +prong_tip.z + 0.25])  block([prong.x, prong.y, 1] + [1, 1, 0.5], center=BELOW + RIGHT);
            } else {            
                block(prong, center=BELOW+LEFT);
                hull() {
                    translate([0, 0, -prong.z]) 
                        block([prong.x, prong.y, prong_tip.z], center=ABOVE+LEFT);
                    translate([0, 0, -prong.z+prong_tip.z]) 
                        block([prong_tip.x, prong_tip.y, 0.01], center=ABOVE+RIGHT);
                }
            }
            
        }
        
       
    }
    prongs(as_clearance = as_clearance);
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
        //
        // Leads
        for (i = [0:1:3]) {
            translate(lead_translations[i]) {
                rotation = is_undef(lead_rotations[i]) ? [0, 0, 0] : lead_rotations[i];
                yaw = rotation.z;
                pitch = rotation.x;
                roll = rotation.y;
                rotate_yaw_pitch_and_roll(yaw, pitch, roll) {
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


module tcrt5000_negative_lead_screw(as_clearance = true, show_nut = true, show_screw = true, show_pin=true) {
    // Negative lead nut - attached to resistors and black pin
    dy_nut = 0.35;
    dz_nut = -6;
    h_screw_access = 10;
    screw_hole_thickness = 2.5;



    side_offset_resistor_lead = 0.9;  
    pin_translation = [
        side_offset_dupont_pin, 
        screw_hole_thickness + nut_tightness_offset, 
        vertical_offset_dupont_pin_n
    ];
    
    translate([dx_negative_nut, dy_negative_nut, dz_negative_nut]) {
        rotate([-90, 0, 0]) {
            if (as_clearance) {
                //rotate([0, 0, -90]) nutcatch_sidecut(name   = "M2",  clh    =  0.5,  clk    =  clk);
                nutcatch_parallel(name   = "M2",  clh    =  10,  clk    =  0.5);  
                translate([0, 0, h_screw_access + screw_hole_thickness]) 
                    hole_through("M2", $fn=12, h = h_screw_access);
             }  else {
                    color(BLACK_IRON) {
                        if (show_nut) {
                            translate([0, 0, -nut_tightness_offset]) nut("M2");
                        }
                        if (show_screw) {
                            translate([0, 0, screw_hole_thickness + nut_tightness_offset]) screw("M2x6", $fn=12);  
                        }
                    }                
            }
        }
        if (as_clearance || show_pin) {
            translate(pin_translation) { 
                dupont_connector(
                    wire_color = "black", 
                    housing_color = "black",         
                    center = BELOW,
                    has_pin = true, 
                    as_clearance = as_clearance);
            }
        } 
        translate([-side_offset_resistor_lead, 0, 0]) {
            if (as_clearance) {
                can(d=d_lead + cl_d_resistor_lead , h = a_lot, $fn=12);
            } else {      
               color("YELLOW") { 
                    can(d=d_lead, h = h_lead, center = BELOW, $fn=12); 
                }
           }
       }
        translate([+side_offset_resistor_lead, 0, 0]) {
            if (as_clearance) {
                can(d=d_lead + cl_d_resistor_lead , h = a_lot, $fn=12);
            } else {      
               color("PURPLE") { 
                    can(d=d_lead, h = h_lead, center = BELOW, $fn=12); 
                }
           }
       }       
    }
}


module tcrt5000_led_lead_screw(as_clearance = true, show_nut = true, show_screw = true, show_pin=false) {
    // For the LED screw, the screw will contact the leads, not the nut.  So hole thickness applied differently
    tcrt5000_default_lead(as_clearance = as_clearance);
    clk = 0.5;
    screw_hole_thickness = 3.5;
    h_screw_access = 10; 
    // Fiddle to get stuff to work out! 
    screw_access_adjustment = 0.7;  
    translate([dx_led_nut, dy_led_nut, dz_led_nut]) {
        rotate([0, 90, 0]) {
            if (as_clearance) {
                translate([0, 0, -screw_hole_thickness]) 
                    rotate([0, 0, -90]) 
                        nutcatch_sidecut(name   = "M2",  clh    =  1.2,  clk = 0.5);
                translate([0, 0, h_screw_access - screw_access_adjustment]) 
                    hole_through("M2", $fn=12, h = h_screw_access, l=4.2);
                // Resistor lead
            } else {
                color(BLACK_IRON) {
                    if (show_nut) {
                       translate([0, 0, -screw_hole_thickness]) nut("M2");
                    } 
                    if (show_screw) {
                         translate([0, 0, 0]) screw("M2x6", $fn=12);
                    }
                }
            }   
        }
        led_bands = ["orange", "orange",  "black", "gold"];
        dy_nut = 0.35;
        day_led_n_for_resistor = 6;
        rotate([-0, -ay_led_n + day_led_n_for_resistor, 0]) { 
            translate([-screw_hole_thickness - nut_tightness_offset, side_offset_resistor_lead, dz_resistor])  {
                resistor(bands=led_bands, h_leds=[2, 10.5], as_clearance=as_clearance);      
            }    
        }        
    }

}


module tcrt5000_sensor_lead_screw(as_clearance = true, show_nut = true, show_screw = true, show_pin) {
    tcrt5000_default_lead(as_clearance = as_clearance);
    screw_hole_thickness = 3.;
    h_screw_access = 10;  
    
    pin_translation = [vertical_offset_dupont_pin_sensor, side_offset_dupont_pin, screw_hole_thickness ];
    sensor_lead_screw  = "M2x6";  
    translate([dx_sensor_nut, dy_sensor_nut, dz_sensor_nut]) {
        rotate([0, -90, 0]) {
            if (as_clearance) {
                rotate([0, 0, -90]) nutcatch_sidecut(name   = "M2",  clh  =  1.2,  clk = 0.5);
                translate([0, 0, h_screw_access + screw_hole_thickness]) 
                    hole_through("M2", $fn=12, h = h_screw_access, l=6.0);
                translate(pin_translation) { 
                    rotate([0, 90, 0]) 
                        dupont_connector(
                        wire_color = "yellow", 
                        housing_color = "yellow",         
                        center = BELOW,
                        has_pin = true, 
                        as_clearance = as_clearance);    
                }
            } else {
                color(BLACK_IRON) {
                    if (show_nut) {
                       translate([0, 0, -nut_tightness_offset]) nut("M2");
                    } 
                    if (show_screw) {
                         translate([0, 0, screw_hole_thickness + nut_tightness_offset]) screw(sensor_lead_screw, $fn=12);
                    }
                }
                if (show_pin) {
                    // Signal_dupont connection
                    translate(pin_translation) {
                        rotate([0, 90, 0]) 
                            dupont_connector(
                                wire_color = "yellow", 
                                housing_color = "yellow",         
                                center = BELOW,
                                has_pin = true, 
                                as_clearance = as_clearance); 
                    }                       
                }
            }

        }
        sensor_bands = ["gray", "red",  "red", "gold"]; 
        rotate([8, -ay_sensor_n, 0]) {
            translate([nut_tightness_offset, side_offset_resistor_lead, dz_resistor])  
                    resistor(bands=sensor_bands, h_leds=[2, 12], as_clearance=as_clearance);   
        }        
    }    
 

     
//        color("yellow") {
//            label("s", dx=-5.5, dy=2.5, size=4);
//        }    
    
//        color("yellow") {
//            label("8.2kΩ", dx=-13, dy=-2.5, size=1.6);
//        }        
}


module tcrt5000_positive_lead_screw(as_clearance = true, show_nut = true, show_screw = true, show_pin = true) {
    h_screw_access = 10;
    clh = 10;
    clk = 0.5;
    dy_nut = 0.5;
    dz_nut = -11;
    dz_dupont_screw = 5;

    

    nut_tightness_offset = -0.35;
    positive_lead_screw = "M2x6";

    pin_translation = [
        -side_offset_dupont_pin, 
        screw_hole_thickness_p + nut_tightness_offset + dy_nut, 
        vertical_offset_dupont_pin_p
    ];  
         
    translate([dx_positive_nut, dy_positive_nut, dz_positive_nut]) {
        rotate([-90, 0, 0]) {
            if (as_clearance) {
                nutcatch_parallel(name   = "M2",  clh    =  clh,  clk    =  clk);  // clearance aditional to nominal key width
                translate([0, 0, h_screw_access + screw_hole_thickness_p]) 
                    hole_through("M2", $fn=12, h = h_screw_access);              
            } else {
                color(BLACK_IRON) {
                    if (show_nut) {
                       translate([0, 0, -nut_tightness_offset]) nut("M2");
                    } 
                    if (show_screw) {
                         translate([0, 0, screw_hole_thickness_p+ dy_nut]) screw(positive_lead_screw, $fn=12);
                    }
                }
            }
        }
        if (as_clearance || show_pin) {
            translate(pin_translation) { 
                dupont_connector(
                    wire_color = "red", 
                    housing_color = "red",         
                    center = BELOW,
                    has_pin = true, 
                    as_clearance = as_clearance);
            }
        }         
    }
    // Slot between the lead
    if (as_clearance) {
        translate([0, dy_lead, 0]) {
            hull() {
                block([2*dx_lead, d_lead + cl_d_lead, 1]);
                translate([0, 0, dz_positive_nut]) sphere(d = d_lead + cl_d_lead);
            }
            //translate([0, 0, dz_positive_lead]) block([2.5, d_lead + cl_d_lead, a_lot], center = BELOW);
        }
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


        
   module blank() {
       block(top_blank, center=ABOVE);
   } 
   module connection_blank() {
       connection_blank = [x_connection_blank, y_connection_blank, z_connection_blank];
        translate([dx_connection_blank, dy_connection_blank, dz_connection_blank]) {
            rounded_block(connection_blank, radius = 2, sidesonly = "YZ", center = BELOW); 
        }
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
    dx_clip_tip = -x_connection_blank - x_strap - cl_dx_clip_tip;
    x_rail = x_connection_blank + x_strap + cl_dx_clip_tip + x_clip_tip;
    dy_latch = -cl_dy_rails - dy_clip_tip_overlap;
    latch_support = [1, dy_clip_tip_overlap + cl_dy_rails, abs(dz_rails)];
    color(PART_2, alpha=1) {
        translate([dx_to_base, dy_connection_blank, 0]) {
            center_reflect([0, 1, 0]) translate([0, dy_rails, dz_rails]) {
                rotate([45, 0, 0]) block([x_rail, 2, 2], center=BEHIND);
                    if (!as_clearance) {
                       // Add clip tip
                       translate([dx_clip_tip, 0, 0]) {
                           hull() {
                                translate([0, dy_latch, 0]) rotate([45, 0, 0]) 
                                    block([1, 2, 2], center=BEHIND);
                                rotate([45, 0, 0]) block([x_clip_tip, 2, 2], center=BEHIND);
                           }
                           translate([0, dy_latch, 0]) {
                               block(latch_support, center = BEHIND+RIGHT+ABOVE);
                               if (mouse_ears) {
                                   translate([0, 2, -dz_rails]) can(d=5, h=0.2, center = BELOW);
                               }
                           }
                        }
                       // Printing support
                       translate([0, 0, 0]) block([x_rail, sqrt(2), abs(dz_rails)], center=BEHIND+RIGHT+ABOVE);
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
                }
                tcrt5000_positive_lead_screw(as_clearance = true);
                //prong_cavity(); 
                clip_rails(as_clearance = true);
                 tcrt5000_negative_lead_screw(as_clearance = true);
                if (show_cross_section) {
                    translate([0, dy_cross_section, 0]) plane_clearance(RIGHT); 
                    translate([dx_cross_section, 0, 0]) plane_clearance(FRONT); 
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
        dx_to_mount = x_connection_blank/2 + dx_connection_blank;
        translation = 
            orient_for_mounting == FRONT ? [dx_to_mount, 0, 0] : 
            orient_for_mounting == BEHIND ? [-dx_to_mount, 0, 0] : 
            orient_for_mounting == LEFT ? [0, -dx_to_mount, 0] : 
            orient_for_mounting == RIGHT ? [0, dx_to_mount, 0] : 
            [0, 0, 0];
        rotation = 
            orient_for_mounting == FRONT ? [0, 0, 180] : 
            orient_for_mounting == BEHIND ? [0, 0, 0] : 
            orient_for_mounting == LEFT ? [0, 0, 90] : 
            orient_for_mounting == RIGHT ? [0, 0, -90] :
            [0, 0, 0] ;
        translate(translation) rotate(rotation) {
            if (show_vitamins) {
                tcrt5000_positive_lead_screw(
                    as_clearance = false, show_nut = show_nuts, show_screw = show_screws, show_pin = show_pins);
                tcrt5000_reflective_optical_sensor(lead_rotations = lead_rotations) {
                    tcrt5000_default_lead();
                    tcrt5000_default_lead();
                    tcrt5000_led_lead_screw(
                        as_clearance = false,  show_nut = show_nuts, show_screw = show_screws, show_pin = show_pins);
                    tcrt5000_sensor_lead_screw(
                        as_clearance = false,  show_nut = show_nuts, show_screw = show_screws, show_pin = show_pins);
                }
                tcrt5000_negative_lead_screw(
                    as_clearance = false, show_nut = show_nuts, show_screw = show_screws, show_pin = show_pins);
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
        orient_for_mounting = orient_for_mounting(orient_for_mounting),
        mouse_ears = true,
        orient_for_printing = orient_for_printing);
}



