// This was a useful design, but not needed ultimately.  
// It would be nice to turn this into a general capability, and get
// dimensioning and clearances worked out. 
// Need to have the camming action useful, while the snap into place
// solid.  And the retention ring could be adjusted to lock into place, 
// and or give and open position for the cams.


// We're not going to use the retainer clip.  But it might be useful in other circumstances
// So that code will be dumped into Apotheka and might eventually be generalized.

h_retainer_clip = 2;  // 3 mm was too tight.  2 mm is minimum.   
od_retainer_clip = 26;



retainer_clip_for_clamp = 0; // [1:Solid, 0.25:Ghostly, 0:"Invisible, won't print" ]
visualization_retainer_clip = 
    visualize_info(
        "Clamp Shaft Retainer Clip", PART_5, retainer_clip_for_clamp, layout_from_mode(layout), show_parts);

module retainer_clip(shaft_clearance=0.4) {
    id_ring = d_retainer_screw_circle + 4;
    id_cams =  d_drive_gear_retainer_shaft + 2*shaft_clearance;
    gap = 0.5;
    module pivot_cutouts() {
        d_cutout = (id_ring - id_cams)/2;
        r_axis = d_drive_gear_retainer_shaft /2 + d_cutout/2 + shaft_clearance;
        offset_axis = r_axis/sqrt(2);
        for (angle = [0 : 90 : 270]) {
            rotate([0, 0, angle]) {
                translate([offset_axis, offset_axis, 0]) {
                    difference() {
                        can(d = d_cutout+2*gap, hollow = d_cutout, h = a_lot);
                        rotate([0, 0, -45]) plane_clearance(FRONT);
                    }
                }
            }
        }
    }
    module shape() {
        render(convexity=10) difference() {
            can(
                d=id_ring-gap, 
                hollow = id_cams, 
                h = h_retainer_clip, 
                center = ABOVE);
            translate([0, 0, 10]) retainer_screws(as_clearance = true);
            pivot_cutouts();
        }
        can(
            d = od_retainer_clip, 
            hollow = id_ring + gap, 
            h = h_retainer_clip, 
            center = ABOVE);
    }
    visualize(visualization_retainer_clip) {
        translate([0, 0, dz_top_of_drive_gear]) { 
            shape();
        }
    }
}