/*

This locks pieces together by rotating the key a quarter turn after insertion. 

If desire, the keyhole can compress the key upon turning.abs
Usage:

    use <ScadApotheka/quarter_turn_clamping_connector.scad>
    




*/

include <ScadStoicheia/centerable.scad>
use <ScadStoicheia/visualization.scad>
include <ScadApotheka/material_colors.scad>


a_lot = 100 + 0;

od_ptfe_tubing = 4 + 0;
d_filament = 1.75;

/* [Example] */
show_ptfe_tubing_collet = true;
show_sample_key_hole = true;
show_qtcc_ptfe_tubing_clip = true;


entrance_diameter = 5;

 major_axis_clamp = 12;
 minor_axis_clamp = 6; 
 height_clamp = 8;
 key_width_clamp = 6;
 core_side_clamp = 6;
 slot_clamp = 1;
 
 major_axis_connector = 10;
 minor_axis_connector = 6;
 height_connector = 6;
 key_width_connector = 6;
core_side_connector = 6;
 slot_connector = 0;

core_length = 0.1;

tube_clearance = 0.25;
filament_clearance = 0.25;
key_clearance = 0.5;
clamping_mm = 2;
module end_of_customization() { }


clamp_dimensions = qtcc_dimensions(
        major_axis_clamp, minor_axis_clamp, height_clamp, key_width_clamp, core_side_clamp, slot_clamp);
connector_dimensions = qtcc_dimensions(
        major_axis_connector, minor_axis_connector,  height_connector, key_width_connector, core_side_connector,  slot_connector);    

if (show_ptfe_tubing_collet) {
    translate([20, 0, 0]) qtcc_ptfe_tubing_collet();
}

if (show_qtcc_ptfe_tubing_clip) {
     translate([0, 0, 0]) qtcc_ptfe_tubing_clip();
}

if (show_sample_key_hole) {
  translate([-20, 0, 0])  qtcc_ptfe_tubing_sample_key_hole();
}

module qtcc_ptfe_tubing_collet() {
    module tubing() {
        can(d=od_ptfe_tubing + 2*tube_clearance, h = height_clamp + core_length/2, center=ABOVE);
    }
    module entrance() {
        translate([0, 0, height_clamp + core_length]) 
            can(d=d_filament+ 2*filament_clearance, taper=entrance_diameter,  h = height_connector + 0.5, center=ABOVE);
    }
    module filament() {
        can(d=d_filament+ 2*filament_clearance, h = a_lot);
    }
    render(convexity=10) difference() {
        quarter_turn_clamping_connector_key(core_length,  clamp_dimensions, connector_dimensions);
        tubing();
        filament();
        entrance();
    }
}
        
module qtcc_ptfe_tubing_clip() {        
    module blank() {
        // TODO
    }
    render(convexity=10) difference() {
        blank();
        quarter_turn_clamping_connector_keyhole(clamp_dimensions, clamping_mm);
    }
} 

module qtcc_ptfe_tubing_sample_key_hole() {
    
    module base() {
        block([20, 20, height_connector + 2], center=ABOVE);
    }
    render(convexity=10) difference() {
        base();
        quarter_turn_clamping_connector_keyhole(connector_dimensions, clamping_mm=0);
    }
}
    
  

function qtcc_dimensions(major_axis, minor_axis, height, key_width, core_side, slot) = [
    major_axis, minor_axis, height, key_width, core_side, slot,
];


module quarter_turn_clamping_connector_key(core_length,  dimensions_1, dimensions_2) {
    assert(is_num(core_length));
    assert(is_list(dimensions_1));
     height_1 = dimensions_1[2];

    // Origin is at center of first dimension pyramids
    module key_shape(dimensions) {
        major_axis = dimensions[0];
        minor_axis = dimensions[1];
        height = dimensions[2];
        key_width = dimensions[3];
        core_side = dimensions[4];
        slot  = dimensions[5];
        major_profile = [major_axis, key_width, 0.1];
        minor_profile= [key_width, minor_axis,0.1];
        core_profile = [core_side, core_side, 0.1];
        
        module blank() {
            hull() {
                block(major_profile, center=ABOVE);
                translate([0, 0, height]) block(core_profile, center=ABOVE);
            }
            hull() {
                block(minor_profile, center=ABOVE);
                translate([0, 0, height]) block(core_profile, center=ABOVE);
            }
        }
        render(convexity = 10) difference() {
            blank();
            block([slot, a_lot, a_lot]);
        }
    }
    module core_shape(first_dimensions, second_dimensions) {

        core_side_1 = first_dimensions[4];
        core_side_2 = is_list(second_dimensions) ? second_dimensions[4] : 0;
        core_side = max(core_side_1, core_side_2);
        core = [core_side, core_side, core_length];
        translate([0, 0, height_1]) block(core, center=ABOVE);
    }

    key_shape(dimensions_1);
    core_shape(dimensions_1, dimensions_2);
    if (is_list(dimensions_2)) {    
       height_2 = dimensions_2[2]; 
        translate([0, 0, height_1 + height_2 + core_length]) rotate([180, 0, 0]) key_shape(dimensions_2);
    } 
}

module quarter_turn_clamping_connector_keyhole(dimensions, clamping_mm) {
    z_clearance = 0.5;
    major_axis = dimensions[0];
    minor_axis = dimensions[1];
    height = dimensions[2];
    key_width = dimensions[3];
    core_side = dimensions[4];
    slot  = dimensions[5];
    major_slot = [major_axis, key_width, height + 2 *z_clearance];
    minor_slot= [key_width, minor_axis, height +2 * z_clearance];
    d_major = sqrt(major_axis^2 + key_width^2);
    d_minor = sqrt(minor_axis^2 + key_width^2);
    sf_clamping = (d_major - clamping_mm)/d_major;
    d_core = sqrt(2) * core_side;
    
    module cavity() {
        translate([0, 0, -z_clearance]) block(major_slot, center=ABOVE);
        translate([0, 0, -z_clearance]) block(minor_slot, center=ABOVE);
        hull() {
            translate([0, 0, height]) scale([1, sf_clamping, 1]) can(d = d_major, h = z_clearance, center=ABOVE);
            can(d = d_core, h = z_clearance, center=BELOW);
        }
    }
    module stops() {
        //translate( , 0]) 
        translate([-key_width/2, minor_axis/2, 0])  block([4, 4, height], center=ABOVE+BEHIND+RIGHT);
        translate([key_width/2, -minor_axis/2, 0])  block([4, 4, height], center=ABOVE+FRONT+LEFT);
    }
    
    render(convexity = 10) difference() {
        cavity();
        stops();
    }
    
    
    
}

