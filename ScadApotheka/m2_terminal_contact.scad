include <ScadStoicheia/centerable.scad>
use <ScadStoicheia/visualization.scad>
include <ScadApotheka/material_colors.scad>    
a_lot = 100 + 0;   
   
screw_offsets = [-20, -14, -8, -0.5, 8];
screw_lengths = [4, 4, 8, 8, 8];
row_one_holes = "Dupont"; // ["Dupont", "Lead", "Thin Lead"]
row_two_holes = "Lead"; // ["Dupont", "Lead", "Thin Lead", "None"]
z_extra_base = 0; //[0, 1, 2]
alpha = 1; // [1:Solid, 0.25:Ghostly, 0:"Invisible, won't print" ]

screw_length = 8; // [4, 6, 8]
show_vitamins = true;
   
 module end_customization() {}  
   
d_row_2 = row_two_holes == "Dupont" ? m2stc_fit_dupont_pin() : 
                row_two_holes ==  "Lead" ? m2stc_fit_lead() : 
                row_two_holes ==  "Thin Lead" ? m2stc_fit_thin_lead() : 
                row_two_holes ==  "None" ? 0 : assert(false);
 
 m2_screw_terminal_contact_strip(
    screw_offsets, screw_lengths, d_row_2=d_row_2,  z_extra_base = z_extra_base, show_vitamins=show_vitamins, color_code=PART_33, alpha=alpha);
   
function m2stc_fit_dupont_pin() = 1.2;
function m2stc_fit_lead() = 1.0;
function m2stc_fit_thin_lead() = 0.8;
   
module m2_screw_terminal_contact_strip(screw_offsets,  screw_lengths, z_extra_base = 0, show_vitamins=true, d_row_2=0, color_code="white", alpha=1) {
    
    module blank() {
        hull() {
            for (i = [0 : len(screw_offsets) - 1]) {
                dy = screw_offsets[i];
                screw_length = screw_lengths[i];
                translate([0, dy, 0]) m2_screw_terminal_contact(screw_length=screw_length, z_extra_base=z_extra_base, as_blank=true);
            }                 
        }        
    }
    
    module shape() {
        render(convexity=10) difference() {
            blank() ;
            for (i = [0 : len(screw_offsets) - 1]) {
                dy = screw_offsets[i];
                screw_length = screw_lengths[i];
                translate([0, dy, 0]) 
                    m2_screw_terminal_contact(screw_length=screw_length, z_extra_base=z_extra_base, as_clearance=true, d_row_2=d_row_2);
            }  
        }
    }
    
    
    if (show_vitamins) {
        for (i = [0 : len(screw_offsets) - 1]) {
            dy = screw_offsets[i];
            screw_length = screw_lengths[i];
            translate([0, dy, 0]) 
                m2_screw_terminal_contact(screw_length=screw_length, z_extra_base=z_extra_base, as_vitamins=true, d_row_2=d_row_2 );
        }  
    }
    color(color_code, alpha) {
        shape();
    }     
}
    

    
    
    
module m2_screw_terminal_contact(
        screw_length, 
        as_clearance=false, 
        as_blank=false, 
        as_vitamins=false, 
        d_row_1=m2stc_fit_dupont_pin() , 
        d_row_2=0, 
        z_extra_base = 0,
        print_from_side = true) {
                       
            
    mode_count = (as_clearance ? 1 : 0) + (as_blank ? 1 : 0) + (as_vitamins ? 1 : 0);
    assert(mode_count == 1);
            
    blank = [7, 7, 8 + z_extra_base];
    dz_nutcatch = 4 + z_extra_base;
    pin_offset = 2.54/2; 
    
            
    h_screwhead = 10;
    dz_row_2 = 2.2;
    dz_screw = dz_nutcatch + dz_row_2;
    dz_screwhead = h_screwhead + dz_nutcatch + dz_row_2;            
    module pin_void(d) {
        rod(d=d, l=a_lot, $fn=12);
        if (print_from_side) {
            rod(d=d+0.5, taper=0.01, l=blank.x/2, center=BEHIND);
        }
        
    }
    if (as_clearance) {

        translate([0, 0, dz_screwhead]) hole_through("M2", $fn=12, cld=0.4, l=20, h=h_screwhead);
        translate([0, 0,  dz_nutcatch])  {
            nutcatch_sidecut(
                name   = "M2",  // name of screw family (i.e. M3, M4, ...) 
                l      = 50.0,  // length of slot
                clk    =  0.5,  // key width clearance
                clh    =  0.5,  // height clearance
                clsl   =  0.1);      
            if (d_row_1 > 0) {
               translate([0, pin_offset, -0.1]) pin_void(d=d_row_1);
               translate([0, -pin_offset, -0.1]) pin_void(d=d_row_1);
            }
            if (d_row_2 > 0) {
               translate([0, pin_offset,  dz_row_2]) pin_void(d=d_row_2);
               translate([0, -pin_offset, dz_row_2]) pin_void(d=d_row_2);      
            }                          
        }
    } else if (as_blank) {
       block(blank, center=ABOVE);          
    } else if (as_vitamins) {
        color(STAINLESS_STEEL) {
            screw_name = str("M2x", screw_length); 
            translate([0, 0, dz_screw]) screw(screw_name, $fn=12);
            translate([0, 0, dz_nutcatch]) nut("M2", $fn=12);
        }  
    } 
}
    
  