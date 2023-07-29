/*

This locks pieces together by rotating the key a quarter turn after insertion. 

If desire, the keyhole can compress the key upon turning.abs
Usage:

    use <ScadApotheka/quarter_turn_clamping_connector.scad>
    

    // TODO: Copy the example here when its working


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

/* [Clearances] */
x_clearance = 0.5;
y_clearance = 0.5;
z_clearance = 0.5;
tube_clearance = 0.25;
filament_clearance = 0.25;
key_clearance = 0.5;


/* [PTFE Clamp Dimensions] */ 
entrance_diameter = 5;

x_clamp = 12;
y_clamp = 6; 
z_clamp = 8;
x_neck_clamp = 7;
x_slot_clamp = 1;

x_connector = 10;
y_connector = 6;
z_connector = 6;
x_neck_connector = 6;
x_slot_connector = 0;

core_length = 0.1;


clamping_mm = 2;
module end_of_customization() { }


clamp_dimensions = qtcc_dimensions(x_clamp, y_clamp, z_clamp, x_clearance, y_clearance, z_clearance, x_neck_clamp, x_slot_clamp);
connector_dimensions = qtcc_dimensions(x_connector, y_connector, z_connector, x_clearance, y_clearance, z_clearance, x_neck_connector, x_slot_connector);  

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
        can(d=od_ptfe_tubing + 2*tube_clearance, h = z_clamp + core_length/2, center=ABOVE);
    }
    module entrance() {
        translate([0, 0, z_clamp + core_length]) 
            can(d=d_filament+ 2*filament_clearance, taper=entrance_diameter,  h = z_connector + 0.5, center=ABOVE);
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
        block([20, 20, z_connector + 2], center=ABOVE);
    }
    render(convexity=10) difference() {
        base();
        quarter_turn_clamping_connector_keyhole(connector_dimensions, clamping_mm=0);
    }
}
    
  

function qtcc_dimensions(x, y, z, x_clearance, y_clearance, z_clearance, x_neck, x_slot) = [
    [x, y, z], 
    [x_clearance, y_clearance, z_clearance],
    x_neck, 
    x_slot, 
];

function gtcc_extent(dimensions) = is_undef(dimensions) ? [0, 0, 0] : dimensions[0];
function gtcc_clearances(dimensions) = is_undef(dimensions) ? [0, 0, 0] : dimensions[1];
function gtcc_x_neck(dimensions) = is_undef(dimensions) ? 0 : dimensions[2];
function gtcc_x_slot(dimensions)  = is_undef(dimensions) ? 0 : dimensions[3];


module quarter_turn_clamping_connector_key(core_length,  dimensions_1, dimensions_2) {
    assert(is_num(core_length));
    assert(is_list(dimensions_1));
    extent_1 = gtcc_extent(dimensions_1);
    extent_2 = gtcc_extent(dimensions_2);
    x_neck_1 = gtcc_x_neck(dimensions_1);
    x_neck_2 =  gtcc_x_neck(dimensions_2);    

    // Origin is at center of first dimension pyramids
    module key_shape(dimensions) {
        extent = gtcc_extent(dimensions);
        x_neck = gtcc_x_neck(dimensions);
        x_slot  = gtcc_x_slot(dimensions); 
        
        base_profile = [extent.x, extent.y, 0.1];
        neck_profile = [x_neck, extent.y, 0.1];
        render(convexity = 10) difference() {
            hull() {
                block(base_profile, center=ABOVE);
                translate([0, 0, extent.z]) block(neck_profile, center=BELOW);
            }
            block([x_slot, a_lot, a_lot]);
        }
    }
    
    module core_shape() {
        core = [max(x_neck_1, x_neck_2), max(extent_1.y, extent_2.y), core_length];
        translate([0, 0, extent_1.z]) block(core, center=ABOVE);
    }


    key_shape(dimensions_1);
    core_shape();
    if (is_list(dimensions_2)) {    
        translate([0, 0, extent_1.z + extent_2.z + core_length]) rotate([180, 0, 0]) key_shape(dimensions_2);
    } 
}

module quarter_turn_clamping_connector_keyhole(dimensions, clamping_mm) {
    extent = gtcc_extent(dimensions);
    clearances = gtcc_clearances(dimensions);
    x_neck =  gtcc_x_neck(dimensions);
//    major_axis = dimensions[0];
//    height = dimensions[2];
//    key_width = dimensions[3];
//    core_side = dimensions[4];
//    slot  = dimensions[5];
//    major_slot = [major_axis, key_width, height + 2 *z_clearance];
//    d_major = sqrt(major_axis^2 + key_width^2);
//    sf_clamping = (d_major - clamping_mm)/d_major;
//    d_core = sqrt(core_side^2 + key_width^2);
//    
    
    d_base = sqrt((extent.x + 2 * clearances.x)^2 + (extent.y + 2* )^2);
    sf_clamping = (d_major - clamping_mm)/d_base;
    module key_insertion_clearance() {
        translate([0, 0, -clearances.x]) block(extent + 2 * clearances, center=ABOVE);
    }
    module base_profile() {
         translate([0, 0, height]) scale([1, sf_clamping, 1]) can(d = d_base, h = clearances.z, center=ABOVE);
    }
    module neck_profile() {
        d_neck = sqrt((x_neck + 2 * clearances.x)^2 + (extent.y + 2* )^2);
         can(d = d_neck, h = clearances.z, center=BELOW);
    }
    module rotation_clearance() {
        hull() {
           base_profile();
           neck_profile() 
        }        
    }
    module cavity() {
        key_insertion_clearance();
        rotation_clearance();
    }
    module quarter_turn_stops() {
//        //translate( , 0]) 
//        translate([-key_width/2, minor_axis/2, 0])  block([4, 4, height], center=ABOVE+BEHIND+RIGHT);
//        translate([key_width/2, -minor_axis/2, 0])  block([4, 4, height], center=ABOVE+FRONT+LEFT);
    }
  
    render(convexity = 10) difference() {
        cavity();
        quarter_turn_stops();
    }
    
    
    
}

