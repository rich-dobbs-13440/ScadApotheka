/*

This is a standoff, that can either be glued to a flat base, or be mounted using screws through the lower base. 

For the initial implementation, I'be using this for Raspberry Pi, so I'll start with 2.5mm screws.

Usage:

use <ScadApotheka/pcb_standoff.scad>

pcb_standoff(screw_family="M2.5", edge = true);

*/


include <ScadStoicheia/centerable.scad>
include <ScadApotheka/material_colors.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>

a_lot = 100.0 + 0.0;

pcb_standoff(orient_for_printing = true);

module pcb_standoff(screw_family="M2.5", h = 4, d = 6, orient_for_printing = false) {
    
    assert(screw_family=="M2.5", "Only implemented for M2.5 at this time");
    module shape() {
        render() difference() {
            
            can(d=9, taper = d, h=h, center=ABOVE);
            translate([0, 0, 25]) hole_through("M2.5", $fn=12);
            translate([0, 0, 2]) nutcatch_parallel("M2.5", clh = a_lot, clk=0.4);
            // Taper roof for better printability
            translate([0, 0, 2]) can(d=5, taper=2.5, h=h-2, center = ABOVE);
        }
    }
    
    rotation = orient_for_printing ? [0, 0, 0] : [0, 0, 0];
    translation = orient_for_printing ? [0, 0, 0] : [0, 0, 0];
    translate(translation) rotate(rotation) shape();
    
    
}
