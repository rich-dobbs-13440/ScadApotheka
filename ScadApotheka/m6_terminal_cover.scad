show_terminal_nut = true;
show_lower_terminal_cover = true;

module end_of_customization();

module m6_terminal_nut() {
  $fn = 20; // Adjust the number of facets for smoothness
    

  // Dimensions
  stud_height = 6; // Height of the M6 stud
  nut_height = 5.2; // Per ISO standard.  Real nuts are more like 4.4 mm.
  nut_across_points = 14.72; // Across points of the 10 mm nut
  cover_height = stud_height + nut_height; // Height of the cover

  // Inner diameter of the annulus (to clear the nut across points)
  annulus_id = nut_across_points + 1; // Adjust as needed to provide clearance

  // Outer diameter and height of the cover
  cover_od = 20;

  // Top portion (screws onto M6 stud)
  translate([0, 0, 0]) {
      difference() {
          translate([0, 0, 0]) cylinder(h=stud_height+2, d = cover_od, $fn=6);      
          cylinder(h = stud_height+10, d = 6); 

    }
  }

  // Lower portion (covers the nut)
  
  translate([0, 0, -nut_height]) {
    difference() {
      cylinder(h = nut_height, d = cover_od); // Outer cylinder
      translate([0, 0, -nut_height])cylinder(h = nut_height + 10, d = annulus_id); // Inner cylinder (annulus)
    }
  }
}

module lower_terminal_cover(height) {
  $fn = 24; // Adjust the number of facets for smoothness

  // Dimensions
  wall_thickness = 2; // Wall thickness for the outer cover
  stud_height = 6; // Height of the M6 stud
  a_lot = 50;
  // Outer diameter and height of the cover
  cover_od = 20;

  // Outer cover retained by the nut) {
    translate([0, 0, -height]) {
        difference([0, 0, -height]) {
          cylinder(d = cover_od + 2 * wall_thickness, h=height);
          translate([0, 0, height-wall_thickness]) cylinder(d = cover_od, h=4);
          cylinder(d = cover_od - 2 * wall_thickness, h=4*height, center=true);
          translate([0, 0, height-2*wall_thickness - a_lot]) cylinder(d = cover_od, h=a_lot);
          translate([55, 0, 0]) cube([100, 100, 100], center=true);
        }

    }

}

// Example usage:
if (show_terminal_nut) {
    m6_terminal_nut(); // Top portion (terminal nut)
}
if (show_lower_terminal_cover) {
    lower_terminal_cover(8); // Lower portion (outer cover) with height = 8mm
}
