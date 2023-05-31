include <nutsnbolts-master/cyl_head_bolt.scad>
include <nutsnbolts-master/data-metric_cyl_head_bolts.scad>


module tuned_M2_nutcatch_side_cut(as_clearance = true) {
    if (as_clearance) {
        nutcatch_sidecut("M2", $fn = 12, clh=.5); 
    } else {
        nut("M2");
    }
}