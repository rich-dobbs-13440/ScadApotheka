/* 
  Usage:
  
  use <ScadApotheka/linear_actuator.scad>
*/

include <ScadStoicheia/centerable.scad>
use <PolyGear/PolyGear.scad>

linear_actuator_standard_servo_bracket(base_mounting_holes=false);


dx = 52.8; // [50: 0.1 : 55]
dx_gear = -89.1; // [-90:0.1:-88]
dy_gear = -15.1; // [-20:0.1:-10]
dz_gear = -10; // [-10:0.1:10]
pressure_angle = 25; // [10:25]
backlash = 0.1; // [0:0.01:0.20]

module linear_actuator_standard_servo_bracket(base_mounting_holes=true) {
    rotate([-90, 0, 0]) {
        render(convexity=10) difference() {
            translate([-68, -38, -16.5]) 
                import("Linear_Servo_Actuators_3170748/files/Motor_Bracket_Large_Version.STL");
            plane_clearance(BELOW);
            plane_clearance(RIGHT);
            plane_clearance(BEHIND);
        }
    }
    if (!base_mounting_holes) {
       block([80, 10, 8.7], center=ABOVE+FRONT+RIGHT);
    }
}


// linear_actuator_standard_servo_pusher(100);



module linear_actuator_standard_servo_pusher(length = 75) {
    module shape() {
        render(convexity=10) difference() {
            rotate([-90, 0, 0]) {
                translate([-42, -15.2, -3.2]) 
                    import("Linear_Servo_Actuators_3170748/files/Pusher_75mm_Long.STL");
                
            }
            plane_clearance(BELOW);
            plane_clearance(BEHIND);
        }
    }
    module extended_shape() {
        for (i = [0 : length/dx]) {
            translate([i*dx, 0, 0]) shape();
        }
    }
    render(convexity=10) difference() {
        extended_shape();
        translate([length, 0, 0]) plane_clearance(FRONT);
    }
}
//teeth = 30;
//length = 100;
//calculated_gear_module = 100/30/PI;
//echo("calculated_gear_module", calculated_gear_module);
//gear_module = 1;

//linear_actuator_standard_servo_gear();

module linear_actuator_standard_servo_gear() {
    color("red") {
        translate([dx_gear, dy_gear,  dz_gear]) {
            import("Linear_Servo_Actuators_3170748/files/Pinion_Gear_Large_Version.STL");
        }
    }
}


*linear_actuator_standard_servo_gear_advanced();

module linear_actuator_standard_servo_gear_advanced() {
    n_teeth = 28;
    gear_height = 6;
    gear_module = 1;
    a_lot = 100;
    render(convexity=10) difference() {
        spur_gear(
            n = n_teeth,  // number of teeth, just enough to clear rider.
            m = gear_module,   // module
            z = gear_height,   // thickness
            pressure_angle = pressure_angle,
            helix_angle    = 0,   // the sign gives the handiness, can be a list
            backlash       = backlash // in module units
        );
        can(d=6, h=a_lot);
        can(d=22, h=a_lot, center=ABOVE);
        center_reflect([1, 0, 0]) translate([17/2, 0, 0]) hole_through("M2", $fn=12);
        center_reflect([0, 1, 0]) translate([0, 17/2, 0]) hole_through("M2", $fn=12);
    }
}
