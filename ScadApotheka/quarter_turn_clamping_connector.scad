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
x_clearance = 0.0;
y_clearance = 0.0;
z_clearance = 00;
tube_clearance = 0.25;
filament_clearance = 0.25;
key_clearance = 0.5;

aspect_ratio_tuning = 1;


/* [PTFE Clamp Dimensions] */ 
entrance_diameter = 5;

x_clamp = 10;
y_clamp = 6; 
z_clamp = 8;
x_neck_clamp = 6;
x_slot_clamp = 1;
// Tune if necessary to hold tube
dx_squeeze_clamp = 3;  
barb_spacing = 2;
barb_bite = 1;

x_connector = 10;
y_connector = 6;
z_connector = 6;
x_neck_connector = 6;
x_slot_connector = 0;
dx_squeeze_connector = 0.1;  // Mostly just take ouot the clearance

core_length = 0.1;
clip_wall = 6;
z_clip = 4;

module end_of_customization() { }


clamp_dimensions = qtcc_dimensions(
    x_clamp, y_clamp, z_clamp, 
    x_clearance, y_clearance, z_clearance, 
    x_neck_clamp, x_slot_clamp, 
    dx_squeeze_clamp, aspect_ratio_tuning);
connector_dimensions = qtcc_dimensions(
    x_connector, y_connector, z_connector, 
    x_clearance, y_clearance, z_clearance, 
    x_neck_connector, x_slot_connector,
    dx_squeeze_connector, aspect_ratio_tuning);  

if (show_ptfe_tubing_collet) {
    translate([20, 0, 0]) qtcc_ptfe_tubing_collet();
}

if (show_qtcc_ptfe_tubing_clip) {
     translate([0, 0, 0]) qtcc_ptfe_tubing_clip();
}

if (show_sample_key_hole) {
  translate([-30, 0, 0])  qtcc_ptfe_tubing_sample_key_hole();
}

module qtcc_ptfe_tubing_collet() {

    barb_count = ceil(z_clamp/barb_spacing);
    module tubing_clearance() {
        for (i = [0: barb_count-1]) {
            translate([0, 0, i*barb_spacing]) 
                can(d=od_ptfe_tubing+2*tube_clearance, taper=od_ptfe_tubing-barb_bite,  h = barb_spacing, center=ABOVE);
        }
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
        tubing_clearance();
        filament();
        entrance();
    }
}
        
module qtcc_ptfe_tubing_clip() { 
    key_extent = gtcc_extent(clamp_dimensions);   
    module blank() {
        block([key_extent.x + 2 * clip_wall, key_extent.x + 2 * clip_wall, z_clip], center=ABOVE);
    }
    module clamping_keyhole() {
        translate([0, 0, key_extent.z + z_clip/2]) 
            rotate([180, 0, 0]) 
                quarter_turn_clamping_connector_keyhole(clamp_dimensions);        
    }
    module tubing() {
        can(d=od_ptfe_tubing + 2 * tube_clearance, h = z_clamp + core_length/2, center=ABOVE);
    }    
    render(convexity=10) difference() {
        blank();
        clamping_keyhole();
        tubing();
    }
} 

module qtcc_ptfe_tubing_sample_key_hole() {
    key_extent = gtcc_extent(connector_dimensions); 
    module base() {
        
        block([20, 20, z_connector - 0.5], center=ABOVE);
        // Bridging support
        center_reflect([0, 1, 0]) 
            translate([0, key_extent.y/2, z_connector]) 
                block([key_extent.x + 5 , key_extent.y, 1], center=RIGHT);
        center_reflect([1, 0, 0]) 
            translate([key_extent.y/2,  0, z_connector+0.25]) 
                block([key_extent.y/2 + 5, key_extent.x, 1], center=ABOVE+FRONT);        
    }
    render(convexity=10) difference() {
        base();
        quarter_turn_clamping_connector_keyhole(connector_dimensions);
    }
}
    
  

function qtcc_dimensions(x, y, z, x_clearance, y_clearance, z_clearance, x_neck, x_slot, dx_squeeze, aspect_ratio_tuning) = [
    [x, y, z], 
    [x_clearance, y_clearance, z_clearance],
    x_neck, 
    x_slot, 
    dx_squeeze,
    aspect_ratio_tuning,
    
];

function gtcc_extent(dimensions) = is_undef(dimensions) ? [0, 0, 0] : dimensions[0];
function gtcc_clearances(dimensions) = is_undef(dimensions) ? [0, 0, 0] : dimensions[1];
function gtcc_x_neck(dimensions) = is_undef(dimensions) ? 0 : dimensions[2];
function gtcc_x_slot(dimensions)  = is_undef(dimensions) ? 0 : dimensions[3];
function gtcc_dx_sqeeze(dimensions)  = is_undef(dimensions) ? 0 : dimensions[4];
function gtcc_aspect_ratio_tuning(dimensions)  = is_undef(dimensions) ? 0 : dimensions[5];

function qtcc_calculate_cam_dimensions(s_open, s_closed, key_width, z_cam, aspect_ratio_tuning) = 
  let(
    radius_open = sqrt(s_open * s_open + key_width * key_width),
    aspect_ratio = aspect_ratio_tuning * s_closed / s_open,
    x_0 = s_open / 2,
    y_0 = key_width / 2,
    denominator = 1 - (y_0^2 / (aspect_ratio^2 * x_0^2)),
    x_cam = 2 * sqrt(x_0^2 / denominator),
    y_cam = x_cam * aspect_ratio
  )
  [x_cam, y_cam, z_cam];


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


module quarter_turn_clamping_connector_keyhole(dimensions) {
    extent = gtcc_extent(dimensions);
    clearances = gtcc_clearances(dimensions);
    x_neck =  gtcc_x_neck(dimensions);
    dx_squeeze = gtcc_dx_sqeeze(dimensions);
    aspect_ratio_tuning = gtcc_aspect_ratio_tuning(dimensions);
    
    
    module cam_shape(cam) {
        scale([cam.x, cam.y, cam.z]) {
            cylinder(h = 1, r = 1, center=true, $fn=30);
        }
    }
    
    module key_insertion_clearance() {
        translate([0, 0, -clearances.x]) block(extent + 2 * clearances, center=ABOVE);
    }
    module base_profile() {
        
        s_open = extent.x + 2*clearances.x;
        s_closed = extent.x - dx_squeeze;
        key_width = extent.y; 
        z_cam = clearances.z;
         cam = qtcc_calculate_cam_dimensions(s_open, s_closed, key_width, z_cam, aspect_ratio_tuning);
         translate([0, 0, extent.z]) scale([cam.x, cam.y, cam.z]) can(d = 1, h =1, center=ABOVE, $fn=50);
    }
    module neck_profile() {
        d_neck = sqrt((x_neck + 2 * clearances.x)^2 + (extent.y + 2 * clearances.y)^2);
         can(d = d_neck, h = clearances.z, center=BELOW);
    }
    module rotation_clearance() {
        hull() {
           base_profile();
           neck_profile();
        }        
    }
    module cavity() {
        key_insertion_clearance();
        rotation_clearance();
    }
    module quarter_turn_stops() {
        stop_offset = extent.y/2 + clearances.y;
        translate([-stop_offset , stop_offset, -0.5])  
            block(extent + [0, 0, 1], center=ABOVE+BEHIND+RIGHT);
        translate([stop_offset , -stop_offset, -0.5])  
            block(extent + [0, 0, 1], center=ABOVE+FRONT+LEFT);
    }
  
    render(convexity = 10) difference() {
        cavity();
        quarter_turn_stops();
    }
    
    
    
}

