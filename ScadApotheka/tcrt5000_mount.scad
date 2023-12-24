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
    show_holder = true;
    show_nuts = true;
    show_screws = true;
    orient_for_printing = true;

/* [Sensor Mount Design] */
    x_padding = 1;
    y_padding = 1;
    z_above = 1;
    x_wall = 5;
    y_wall = 1;
    cl_wall = 0.5;
    cl_d_lead = 1;
    
    cl_prong_tip = 0.6;
    cl_d_registration_pin = 1;
    cl_x_prong = 0.25;
    
/* [Wire design] */
    ay_center = -15;
    ay_spread = 15;
    ay_join = 25;
    dx_resistor_nuts = 5;
    dx_resistor_lead_sensor = -5.8;
    dx_resistor_lead_led = 5.5;
    dx_negative_nut = -10;
    x_connection_blank = 24;
    y_connection_blank = 12;
    z_connection_blank = 10;
    dx_connection_blank = -2;
    dy_connection_blank = 2.35;
    cl_connection_d_lead = 0.8;
    dy_dupont_pin = 4.5;

module end_of_customization() {}


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
        color(CHROME) {
            for (i = [0:1:3]) {
                translate(lead_translations[i]) {
                    rotation = is_undef(lead_rotations[i]) ? [0, 0, 0] : lead_rotations[i];
                    rotate(rotation) {
                         can(d=d_lead, h=h_lead, center=BELOW, $fn=12);
                         if (as_clearance) {
                             echo("child_count", child_count);
                             if (i < child_count) {
                                 children(i);
                             } else {                             
//                                can(d=d_lead + cl_d_lead, h=h_lead, center=BELOW, $fn=12);
//                                can(d = d_lead, taper=2, h = 4, center=BELOW, $fn=12);
                             }
                         }
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


module connection_screws(as_clearance = true, show_nuts = true, show_screws = true) {
    h_screw_access = 10;
    clh = 10;
    clk = 0.5;
    dy_nut = .25;
    dz_dupont_screw = 5;
    
    color(BLACK_IRON) {
        // Positive lead nut
        translate([0, dy_lead + dy_nut, -7]) {
            rotate([-90, 0, 0]) {
                if (as_clearance) {
                    nutcatch_parallel(name   = "M2",  clh    =  clh,  clk    =  clk);  // clearance aditional to nominal key width
                    translate([0, 0, 2 + h_screw_access - 2 * dy_nut]) hole_through("M2", $fn=12, h = h_screw_access);
                } else {
                    if (show_nuts) {
                        nut("M2");
                    }
                    if (show_screws) {
                        translate([0, 0, dz_dupont_screw]) screw("M2x8", $fn=12);
                    }
                }
            }
        }
        // Nut attaching resistors on back of sensor
        translate([dx_resistor_nuts, -dy_lead + dy_nut, -5]) {
            rotate([-90, 0, 0]) {
                if (as_clearance) {
                    nutcatch_parallel(name   = "M2",  clh    =  clh,  clk    =  clk);  // clearance aditional to nominal key width
                    translate([0, 0, 2 + h_screw_access - 2 * dy_nut]) hole_through("M2", $fn=12, h = h_screw_access);
                } else {                
                    if (show_nuts) {
                        nut("M2");
                    }
                    translate([0, 0, 2]) screw("M2x4", $fn=12);
                }
            }
        }
        // Nut attach resistor and signal dupont lead
        translate([-dx_resistor_nuts, -dy_lead + dy_nut, -5]) {
            rotate([-90, 0, 0]) {
                if (as_clearance) {
                    nutcatch_parallel(name   = "M2",  clh    =  clh,  clk    =  clk);  // clearance aditional to nominal key width
                    translate([0, 0, 2 + h_screw_access - 2 * dy_nut]) hole_through("M2", $fn=12, h = h_screw_access);
                } else {                
                    if (show_nuts) {
                        nut("M2");
                    }
                    translate([0, 0, dz_dupont_screw  + 2 * dy_lead]) screw("M2x10", $fn=12);
                }
            }
        }        
        // Nut for attaching resistor leads to ground dupont 
        translate([dx_negative_nut, -dy_lead + dy_nut, -7]) {
            rotate([-90, 0, 0]) {
                if (as_clearance) {
                    nutcatch_parallel(name   = "M2",  clh    =  clh,  clk    =  clk);  // clearance aditional to nominal key width
                    translate([0, 0, 2 + h_screw_access - 2 * dy_nut]) hole_through("M2", $fn=12, h = h_screw_access);
                } else {  
                    if (show_nuts) {
                        nut("M2");
                    }
                    if (show_screws) {
                        translate([0, 0, dz_dupont_screw  + 2 * dy_lead]) screw("M2x10", $fn=12);
                    }
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
    // Negative dupont connection
    translate([dx_negative_nut + 0.8, dy_dupont_pin, -11]) {
            dupont_connector(
            wire_color = "black", 
            housing_color = "black",         
            center = BELOW,
            has_pin = true, 
            as_clearance = as_clearance);
    }
    // Signal_dupont connection
    translate([-dx_resistor_nuts + 0.8, dy_dupont_pin, -9]) {
            dupont_connector(
            wire_color = "yellow", 
            housing_color = "yellow",         
            center = BELOW,
            has_pin = true, 
            has_wire = false,
            as_clearance = as_clearance);
    } 
    d_lead_w_cl = as_clearance ? d_lead + cl_connection_d_lead : d_lead;
//    color("RED") {
//        // Bend of positive supply wires
//        center_reflect([1, 0, 0]) 
//            translate([-dx_lead, dy_lead, -2]) 
//                rotate([0, ay_center, 0]) 
//                    can(d=d_lead_w_cl, h = h_lead, center = BELOW, $fn=12); 
//    }
//    color("GREEN") {    
//        // Bend ground side leads away from supply
//        center_reflect([1, 0, 0]) 
//            translate([-dx_lead, -dy_lead, -2]) 
//                rotate([0, ay_spread, 0]) 
//                    can(d=d_lead_w_cl, h = h_lead, center = BELOW, $fn=12); 
//    }
    // First resistor lead     
    color("YELLOW") { 
        translate([dx_resistor_lead_sensor, -dy_lead, -2]) 
            can(d=d_lead_w_cl, h = h_lead, center = BELOW, $fn=12);
    }
    // Second resistor lead   
    color("PURPLE") {
        translate([dx_resistor_lead_led, -dy_lead, -2]) 
            rotate([0, ay_join, 0])  
                can(d=d_lead_w_cl, h = h_lead, center = BELOW, $fn=12); 
    }
   // Resistor leads to negative nuts
   
   translate([dx_negative_nut, -dy_lead, -2]) {
       color("YELLOW") { 
           translate([-0.8, 0, 0]) {
               can(d=d_lead_w_cl, h = h_lead, center = BELOW, $fn=12); 
           }
       }
       color("PURPLE") {
           translate([0.8, 0, 0]) {
               can(d=d_lead_w_cl, h = h_lead, center = BELOW, $fn=12); 
           }
       }           
   }
}

module tcrt5000_reflective_optical_sensor_holder(
    x_padding = x_padding, y_padding = y_padding, z_above = z_above) {
   top_blank = [sensor_body.x + 2 * x_padding, sensor_body.y + 2 * y_padding, z_above];
   z_below = prong.z - prong_tip.z - cl_prong_tip;
   bottom_blank = [sensor_body.x + 2 * x_wall, sensor_body.y + 2 * y_wall, z_below];
        
   lead_rotations = [
        [0, ay_center, 0],
        [0, -ay_center, 0],
        [0, -ay_spread, 0],
        [0, ay_spread, 0]
    ];
        
   module blank() {
       block(top_blank, center=ABOVE);
       block(bottom_blank, center=BELOW);
   } 
   module connection_blank() {
       connection_blank = [x_connection_blank, y_connection_blank, z_connection_blank];
        translate([dx_connection_blank, dy_connection_blank, -z_below]) block(connection_blank, center=BELOW);
//       translate([dx_connection_blank, 0, -z_below]) block(connection_blank, center=BELOW);
//       connection_base = [8, 8, 4];
//       translate([1, 2, -z_below - connection_blank.z]) block(connection_base, center=ABOVE);
   }
   module prong_cavity() {
       translate([0, 0, -z_below]) block([2, a_lot, 2], center=BELOW);
       
   }
   module lead_cavity(dz_pinch = -h_lead/2) {
       d_lead_w_cl = d_lead + cl_connection_d_lead;
       pairwise_hull() {
           sphere(d=d_lead_w_cl); 
           translate([0, 0, dz_pinch]) sphere(d=d_lead + 0.5); 
           translate([0, 0, -h_lead]) sphere(d=d_lead_w_cl +1); 
       }
   }
    module shape() {
        
        difference() {
            union() {
                blank();
                connection_blank();
            }
            tcrt5000_reflective_optical_sensor(as_clearance=true, lead_rotations = lead_rotations) {
                lead_cavity(dz_pinch = -8);
                lead_cavity(dz_pinch = -8);
                lead_cavity(dz_pinch = -6);
                lead_cavity(dz_pinch = -6);
            }
            connection_screws(as_clearance = true);
            prong_cavity();            
        }
    }
    if (show_vitamins) {
        connection_screws(as_clearance = false, show_nuts = show_nuts);
        tcrt5000_reflective_optical_sensor(lead_rotations = lead_rotations);
    }
    color(PART_1, alpha=1) shape();
}

if (show_holder) {
    tcrt5000_reflective_optical_sensor_holder();
}


