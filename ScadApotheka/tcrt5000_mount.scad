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

/* [Sensor Mount Design] */
    x_padding = 1;
    y_padding = 2;
    z_above = 1;
    x_wall = 3;
    y_wall = 2;
    cl_wall = 0.5;
    cl_d_lead = 1;
    
    cl_prong_tip = 0.6;
    cl_d_registration_pin = 1;
    cl_x_prong = 0.25;
    
/* [Wire design] */
    ay_center = -20;
    ay_spread = 25;
    ay_join = 25;
    dx_resistor_nuts = 5;
    dx_resistor_lead_sensor = -5.5;
    dx_resistor_lead_led = 5.5;
    dx_negative_nut = -10;
    z_connection_blank = 10;
    dx_connection_blank = -6;
    cl_connection_d_lead = 0.5;

module end_of_customization() {}


module tcrt5000_reflective_optical_sensor(as_clearance = false, h_lead = h_lead) {
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
    module shape() {
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
            translate([-sensor_body.x/2, -sensor_body.y/2, 0]) can(d=d_pin, h=h_registration_pin, center=BELOW);
            block(shield, center=ABOVE);
            prongs();
            if (as_clearance) {
                prong_cavity = [prong.x + 2 * cl_x_prong, sensor_body.y, a_lot];
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
            center_reflect([1, 0, 0])  center_reflect([0, 1, 0]) {
                translate([dx_lead, dy_lead, 0]) {
                    can(d=d_lead, h=h_lead, center=BELOW, $fn=12);
                     if (as_clearance) {
                         can(d=d_lead + cl_d_lead, h=h_lead, center=BELOW, $fn=12);
                         can(d = d_lead, taper=2, h = 4, center=BELOW, $fn=12);
                     }
                 }
            }
        }
    }
    shape();

    
}
if (show_vitamins) {
    tcrt5000_reflective_optical_sensor(h_lead = 10);
}

module connection_screws(as_clearance = true) {
    h_screw_access = 10;
    clh = 10;
    clk = 0.5;
    dy_nut = .25;
    color(BLACK_IRON) {
        // Positive lead nuts
        translate([0, dy_lead + dy_nut, -7]) {
            rotate([-90, 0, 0]) {
                if (as_clearance) {
                    nutcatch_parallel(name   = "M2",  clh    =  clh,  clk    =  clk);  // clearance aditional to nominal key width
                    translate([0, 0, 2 + h_screw_access - 2 * dy_nut]) hole_through("M2", $fn=12, h = h_screw_access);
                } else {
                    nut("M2");
                    translate([0, 0, 2]) screw("M2x4", $fn=12);
                }
            }
        }
        // Nuts attaching resistors on back of sensor
        center_reflect([1, 0, 0]) translate([dx_resistor_nuts, -dy_lead + dy_nut, -5]) {
            rotate([-90, 0, 0]) {
                if (as_clearance) {
                    nutcatch_parallel(name   = "M2",  clh    =  clh,  clk    =  clk);  // clearance aditional to nominal key width
                    translate([0, 0, 2 + h_screw_access - 2 * dy_nut]) hole_through("M2", $fn=12, h = h_screw_access);
                } else {                
                    nut("M2");
                    translate([0, 0, 2]) screw("M2x4", $fn=12);
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
                    nut("M2");
                    translate([0, 0, 2]) screw("M2x4", $fn=12);
                }
            }            
        }
    }
    // Positive dupont connection
    translate([0.8, dy_lead  + 2, -11]) {
            dupont_connector(
            wire_color = "red", 
            housing_color = "red",         
            center = BELOW,
            has_pin = true, 
            as_clearance = as_clearance);
    }
    // Negative dupont connection
    translate([dx_negative_nut + 0.8, -dy_lead  + 2, -11]) {
            dupont_connector(
            wire_color = "black", 
            housing_color = "black",         
            center = BELOW,
            has_pin = true, 
            as_clearance = as_clearance);
    }
    // Signal_dupont connection
    translate([-dx_resistor_nuts + 0.8, -dy_lead  + 2, -9]) {
            dupont_connector(
            wire_color = "yellow", 
            housing_color = "yellow",         
            center = BELOW,
            has_pin = true, 
            as_clearance = as_clearance);
    } 
    d_lead_w_cl = as_clearance ? d_lead + cl_connection_d_lead : d_lead;
    color("RED") {
        // Bend of positive supply wires
        center_reflect([1, 0, 0]) 
            translate([-dx_lead, dy_lead, -2]) 
                rotate([0, ay_center, 0]) 
                    can(d=d_lead_w_cl, h = h_lead, center = BELOW, $fn=12); 
    }
    color("GREEN") {    
        // Bend ground side leads away from supply
        center_reflect([1, 0, 0]) 
            translate([-dx_lead, -dy_lead, -2]) 
                rotate([0, ay_spread, 0]) 
                    can(d=d_lead_w_cl, h = h_lead, center = BELOW, $fn=12); 
    }
    // First resistor lead     
    color("YELLOW") { 
        translate([dx_resistor_lead_sensor, -dy_lead, -2]) 
            can(d=d_lead_w_cl, h = h_lead, center = BELOW, $fn=12);
    }
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
   module blank() {
       block(top_blank, center=ABOVE);
       block(bottom_blank, center=BELOW);
   } 
   module connection_blank() {
       connection_blank = [bottom_blank.x, bottom_blank.y, z_connection_blank];
       translate([0, 0, -z_below]) block(connection_blank, center=BELOW);
       translate([dx_connection_blank, 0, -z_below]) block(connection_blank, center=BELOW);
   }
   module prong_cavity() {
       translate([0, 0, -z_below]) block([2, a_lot, 2], center=BELOW);
       
   }
    module shape() {
        render() difference() {
            blank();
            tcrt5000_reflective_optical_sensor(as_clearance=true);
        }
        difference() {
            connection_blank();
            connection_screws(as_clearance = true);
            prong_cavity();
        }
    }
    if (show_vitamins) {
        connection_screws(as_clearance = false);
    }
    color(PART_1, alpha=1) shape();
}

tcrt5000_reflective_optical_sensor_holder();


