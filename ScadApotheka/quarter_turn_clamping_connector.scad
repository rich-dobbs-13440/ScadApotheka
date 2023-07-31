/*

This locks pieces together by rotating the key a quarter turn after insertion. 

If desire, the keyhole can compress the key upon turning.abs
Usage:

    use <ScadApotheka/quarter_turn_clamping_connector.scad>
    

    render(convexity=10) difference() {
        base();
        entrance();        
        translate(from_base_plate_to_where_used) qtcc_ptfe_tubing_connector_keyhole();
    }
    
    
    translate([dx_for_printing, dy_for_printing, 0]) qtcc_ptfe_tubing_collet();
    
    
    translate([dx_for_printing, dy_for_printing, 0]) qtcc_ptfe_tubing_clip();

*/

include <ScadStoicheia/centerable.scad>
use <ScadStoicheia/visualization.scad>
include <ScadApotheka/material_colors.scad>


a_lot = 100 + 0;

od_ptfe_tubing = 4 + 0;
d_filament = 1.75 + 0;

/* [Example] */
show_assembled = false;

show_ptfe_tubing_collet = true;
show_sample_key_hole = true;
show_qtcc_ptfe_tubing_clip = true;


/* [Animation] */

az_clip = 0; //[0:90]
dz_crossection =-1; // [-1:0.1:3]

alpha_clip = 1; //[1: Solid, 0.25: Ghostly, 0:Invisible]

/* [Clearances] */
x_clearance = 0.25;
y_clearance = 0.25;
z_clearance = 0.25;
tube_clearance = 0.25;
loose_tube_clearance = 1;
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
dx_squeeze_clamp = 1.5; // [0:0.25:3]  
barb_spacing = 2;
barb_bite = 0.5;

x_connector = 10;
y_connector = 6;
z_connector = 6;
x_neck_connector = 6;
x_slot_connector = 0;
// Tune if necessary to hold connector in keyhole
dx_squeeze_connector = 1.5;  

core_length = 0.1;
clip_wall = 3;
z_clip = 6;
dz_clip_base = 1.75;

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
    rotation = [0, 0, 0];
    translation = show_assembled ? [0, 0, dz_clip_base] : [20, 0, 0]; 
    translate(translation) rotate(rotation) qtcc_ptfe_tubing_collet();
}

if (show_qtcc_ptfe_tubing_clip) {
     translate([0, 0, 0]) rotate([0, 0, az_clip])  qtcc_ptfe_tubing_clip();
}

if (show_sample_key_hole) {
    
  translate([-30, 0, 0])  qtcc_ptfe_tubing_sample_key_hole();
}

module qtcc_ptfe_tubing_collet() {

    barb_count = ceil(z_clamp/barb_spacing);
    module tubing_clearance() {
        id = od_ptfe_tubing+2*tube_clearance;
        for (i = [0: barb_count-1]) {
            translate([0, 0, i*barb_spacing]) 
                can(d=id, taper=id-barb_bite,  h = barb_spacing, center=ABOVE);
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
    s_clip = 2 * ceil((key_extent.x + 2 * clip_wall)/2);
    echo("s_clip", s_clip);
    module blank() {
        block([s_clip, s_clip, z_clip], center=ABOVE);
    }
    module clamping_keyhole() {
        translate([0, 0, key_extent.z + dz_clip_base]) 
            rotate([180, 0, 0]) 
                quarter_turn_clamping_connector_keyhole(clamp_dimensions);        
    }
    module tubing() {
        can(d=od_ptfe_tubing + 2 * loose_tube_clearance, h = z_clamp + core_length/2, center=ABOVE);
    }    
    color(PART_20, alpha = alpha_clip) {
        render(convexity=10) difference() {
            blank();
            clamping_keyhole();
            tubing();
            translate([0, 0, dz_crossection]) plane_clearance(BELOW);
        }
    }
} 

module qtcc_ptfe_tubing_connector_keyhole() {
    quarter_turn_clamping_connector_keyhole(connector_dimensions);
}


module qtcc_ptfe_tubing_sample_key_hole() {
    key_extent = gtcc_extent(connector_dimensions); 
    module entrance() {
        can(d=entrance_diameter, h=a_lot);
    }
    
    module base() {
        block([20, 20, z_connector + 2], center=ABOVE);  
    }
    render(convexity=10) difference() {
        base();
        entrance();        
        qtcc_ptfe_tubing_connector_keyhole();
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
    iar = 1/aspect_ratio,
    x_0 = s_open / 2,
    y_0 = key_width / 2,
    x_cam = sqrt(x_0^2  + (iar^2*y_0^2)),
    y_cam = x_cam*aspect_ratio
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
            if (x_slot > 0) {
                block([x_slot, a_lot, a_lot]);
            }
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
        z_bridging = 0.5;
        translate([0, 0, -clearances.x]) block(extent + 2 * clearances + [0, 0, z_bridging], center=ABOVE);
        translate([0, 0, extent.z+clearances.z + z_bridging]) block([extent.y, extent.y, z_bridging], center=ABOVE);
    }
    module base_profile() {
        
        s_open = extent.x + 2*clearances.x;
        s_closed = extent.x - dx_squeeze;
        key_width = extent.y; 
        z_cam = clearances.z;
        echo("s_open", s_open);
        echo("s_closed", s_closed);
        cam = qtcc_calculate_cam_dimensions(s_open, s_closed, key_width, z_cam, aspect_ratio_tuning);
        //cam = calculate_cam_dimensions(s_open, s_closed, key_width, z_cam, aspect_ratio_tuning);
        translate([0, 0, extent.z]) cam_shape(cam);
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

