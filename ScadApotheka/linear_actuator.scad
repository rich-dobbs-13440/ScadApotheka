

include <ScadStoicheia/centerable.scad>

*linear_actuator_standard_servo_bracket();


dx = 52.8; // [50: 0.1 : 55]


module linear_actuator_standard_servo_bracket() {
    rotate([-90, 0, 0]) {
        render(convexity=10) difference() {
            translate([-68, -38, -16.5]) import("Linear_Servo_Actuators_3170748/files/Motor_Bracket_Large_Version.STL");
            plane_clearance(BELOW);
            plane_clearance(RIGHT);
            plane_clearance(BEHIND);
        }
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
teeth = 30;
length = 100;
gear_module = 100/30;
echo("gear_module", gear_module);


linear_actuator_standard_servo_gear();

module linear_actuator_standard_servo_gear() {
    translate([-90, 0, 0]) import("Linear_Servo_Actuators_3170748/files/Pinion_Gear_Large_Version.STL");
}
