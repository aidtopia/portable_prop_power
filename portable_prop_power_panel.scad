// Portable Prop Power
// Adrian McCarthy 2024-03-14

Include_Base = true;
Include_Box_Walls = true;
Wall_Height = 64; // [20:80]
Include_Control_Panel = true;
Show_Tobsun_Buck = true;
Show_LM2596_Buck = true;

module __Customizer_Limit__ () {}

use <aidthread.scad>

function inch(x) = 25.4*x;

module brace(p0, p1, brace_th=2, nozzle_d=0.4) {
    linear_extrude(brace_th + 0.1, convexity=4, center=true) {
        hull() {
            translate(p0) circle(d=brace_th, $fs=nozzle_d/2);
            translate(p1) circle(d=brace_th, $fs=nozzle_d/2);
        }
    }
}

module rectangular_brace(size, panel_th, margin=undef, nozzle_d=0.4) {
    brace_th = panel_th;
    m       = is_undef(margin) ? max(min(4, brace_th), brace_th/2) : margin;
    left    = -(size.x/2 + m);
    top     = size.y/2 + m;
    right   = -left;
    bottom  = -top;
    translate([0, 0, -panel_th+0.1]) {
        brace([left, top],     [left, bottom],  brace_th, nozzle_d);
        brace([left, bottom],  [right, bottom], brace_th, nozzle_d);
        brace([right, bottom], [right, top],    brace_th, nozzle_d);
        brace([right, top],    [left, top],     brace_th, nozzle_d);
    }
}


// Plastic Button
// https://www.amazon.com/dp/B07F24Y1TB
function plasticbtn_size(panel_th=0) = [17.5, 17.5, 4];

module plasticbtn_support(panel_th, nozzle_d=0.4) {
    support_dia  = plasticbtn_size().x;
    button_depth = plasticbtn_size().z;
    translate([0, 0, panel_th/2 - button_depth])
        cylinder(h=button_depth, d=support_dia);
}

module plasticbtn_cutout(panel_th, nozzle_d=0.4) {
    button_dia   = plasticbtn_size().x;
    button_depth = plasticbtn_size().z;
    translate([0, 0, panel_th/2 - button_depth - 0.1]) {
        AT_threads(h=button_depth + 0.2, d=12, pitch=0.75, tap=true,
                   nozzle_d=nozzle_d);
        translate([0, 0, button_depth-1])
            cylinder(h=1+panel_th/2+0.1, d=13);
    }
}


function panel_fuse_size(panel_th=0) = [17.5, 17.5, 4];

module panel_fuse_support(panel_th, nozzle_d=0.4) {
    support_dia  = plasticbtn_size().x;
    button_depth = plasticbtn_size().z;
    translate([0, 0, panel_th/2 - button_depth])
        cylinder(h=button_depth, d=support_dia);
}

module panel_fuse_cutout(panel_th, nozzle_d=0.4) {
    button_dia   = plasticbtn_size().x;
    button_depth = plasticbtn_size().z;
    translate([0, 0, panel_th/2 - button_depth - 0.1]) {
        AT_threads(h=button_depth + 0.2, d=12, pitch=1, tap=true,
                   nozzle_d=nozzle_d);
        translate([0, 0, button_depth-1])
            cylinder(h=1+panel_th/2+0.1, d=13);
    }
}

// Meter Module
// 0.28" voltage and amperage panel-mount meter
// https://www.amazon.com/dp/B08HQM1RMF
function metermod_size(panel_th=0) = [48, 29];

module metermod_support(panel_th, nozzle_d=0.4) {
    rectangular_brace(metermod_size(), panel_th, nozzle_d=nozzle_d);
}

module metermod_cutout(panel_th, nozzle_d=0.4) {
    cutout_w = 45 + nozzle_d;
    cutout_h = 26.2 + nozzle_d;
    cube([cutout_w, cutout_h, panel_th+0.1], center=true);
}

// Rocker Switch
// Daier KCD-101 rocker switch
// https://www.chinadaier.com/kcd1-101-10-amp-rocker-switch/
function rocker_size(panel_th=0) = [15, 21];

module rocker_support(panel_th, nozzle_d=0.4) {
    rectangular_brace(rocker_size(), panel_th, nozzle_d=nozzle_d);
}

module rocker_cutout(panel_th, nozzle_d=0.4) {
    cutout_w = 13.2;
    cutout_h = 19.2 + nozzle_d;
    cube([cutout_w, cutout_h, panel_th+0.1], center=true);
}

function recessed_rocker_size(panel_th) = [
    rocker_size(panel_th).x + panel_th,
    rocker_size(panel_th).y + panel_th, 6
];

function Wago221_holder_size(conductors=3, nozzle_d=0.4) =
    let(th = 2,
        w = (conductors == 2) ? 13.0 :
            (conductors == 3) ? 18.6 :
            (conductors == 5) ? 29.8 : 0,
        d = 8.2)
    [w+2*th, d+2*th];  // TODO: z component

module Wago221_holder(conductors=3, nozzle_d=0.4) {
    th = 2;
    w =
        (conductors == 2) ? 13.0 :
        (conductors == 3) ? 18.6 :
        (conductors == 5) ? 29.8 : 0;
    lever_w =
        (conductors == 2) ? 11.1 :
        (conductors == 3) ? 17.3 :
        (conductors == 5) ? 27.8 : 0;
    tab_w = 8;
    tab_lip = 2.5;
    h = 18.2;
    base_h = 3.5;
    d = 8.2;
    linear_extrude(th) square([w+2*th, d+2*th], center=true);
    translate([0, 0, th]) {
        difference() {
            linear_extrude(h+tab_lip, convexity=8) {
                difference() {
                    square([w+2*th, d+2*th], center=true);
                    square([w+nozzle_d/2, d+nozzle_d/2], center=true);
                }
            }
            translate([0, -d/2, base_h]) {
                linear_extrude(h+th, convexity=8) {
                    square([lever_w, d], center=true);
                }
            }
            translate([0, d/2, 2*base_h]) {
                linear_extrude(h+th, convexity=8) {
                    translate([-tab_w/2, 0])
                        square([nozzle_d, 2*th+nozzle_d], center=true);
                    translate([ tab_w/2, 0])
                        square([nozzle_d, 2*th+nozzle_d], center=true);
                }
            } 
        }
        translate([0, (d+nozzle_d)/2, h+tab_lip]) rotate([-90, 0, 0]) rotate([0, 90, 0]) {
            linear_extrude(tab_w-nozzle_d, center=true) {
                polygon([[0, 0], [tab_lip, th/2], [0, th]]);
            }
        }
    }
}

function Tobsun_buck_size() = [64, 53];

module Tobsun_buck(nozzle_d=0.4) {
    module slot() {
        hull() {
            translate([0, -1.5]) circle(d=3, $fs=nozzle_d/2);
            translate([0,  1.5]) circle(d=3, $fs=nozzle_d/2);
        }
    }

    color("gray") {
        linear_extrude(2, convexity=8) {
            translate([0, -7.5]) difference() {
                hull() {
                    translate([-57/2, 0]) circle(d=7, $fs=nozzle_d/2);
                    translate([ 57/2, 0]) circle(d=7, $fs=nozzle_d/2);
                    square([50, 18], center=true);
                }
                translate([-57/2, 0]) circle(d=3, $fs=nozzle_d/2);
                translate([ 57/2, 0]) circle(d=3, $fs=nozzle_d/2);
            }
            difference() {
                square([50, 53], center=true);
                translate([-42/2, 53/2-5.5]) slot();
                translate([ 42/2, 53/2-5.5]) slot();
            }
        }
        linear_extrude(20, convexity=8) {
            translate([0, -7.5]) square([50, 38], center=true);
        }
        translate([0, (53-15)/2, 4])
            linear_extrude(15, convexity=8)
                square([35, 15], center=true);
    }
}

module Tobsun_buck_pilot_holes(nozzle_d=0.4) {
    dia = 2.5 + nozzle_d;  // tap size for M3
    translate([0, -7.5, -10]) {
        linear_extrude(10.1, convexity=4) {
            translate([-57/2, 0]) circle(d=dia, $fs=nozzle_d/2);
            translate([ 57/2, 0]) circle(d=dia, $fs=nozzle_d/2);
        }
    }
}

function LM2596_buck_size() = [43.5, 21.3];

module LM2596_buck(nozzle_d=0.4) {
    pcb_th = 1.6;
    translate([0, 0, 2]) {
        color("blue") linear_extrude(pcb_th) {
            difference() {
                square(LM2596_buck_size(), center=true);
                dx = 30/2; dy= 15/2;
                translate([-dx,  dy]) circle(d=3, $fs=nozzle_d/2);
                translate([ dx, -dy]) circle(d=3, $fs=nozzle_d/2);
            }
        }
        translate([0, 0, pcb_th]) {
            color("white") linear_extrude(10) {
                dx = 34.8/2;
                translate([-dx, 0]) circle(d=8, $fs=nozzle_d/2);
                translate([ dx, 0]) circle(d=8, $fs=nozzle_d/2);
            }
        }
    }
}

module LM2596_buck_supports(nozzle_d=0.4) {
    dia = 5.5;
    linear_extrude(2, convexity=4) {
        dx = 30/2; dy= 15/2;
        translate([-dx,  dy]) circle(d=dia, $fs=nozzle_d/2);
        translate([ dx, -dy]) circle(d=dia, $fs=nozzle_d/2);
    }
}

module LM2596_buck_pilot_holes(nozzle_d=0.4) {
    dia = 2.5 + nozzle_d;  // tap size for M3
    translate([0, 0, -10+2]) {
        linear_extrude(10.1, convexity=4) {
            dx = 30/2; dy= 15/2;
            translate([-dx,  dy]) circle(d=dia, $fs=nozzle_d/2);
            translate([ dx, -dy]) circle(d=dia, $fs=nozzle_d/2);
        }
    }
}

module power_footprint(w, h, r, nozzle_d=0.4) {
    offset(r=r, $fs=nozzle_d/2) offset(r=-r) square([w, h]);
}

module panel(
    panel_w=inch(5+1/8), panel_h=inch(3+1/2),
    panel_th=1.8,
    print_orientation=false,
    nozzle_d=0.4
) {
    module footprint() {
        power_footprint(panel_w, panel_h, 5, nozzle_d=nozzle_d);
    }
    
    module panel() {
        linear_extrude(panel_th, center=true) footprint();
        translate([0, 0, -panel_th]) {
            linear_extrude(panel_th, center=true) {
                difference() {
                    offset(r=-panel_th-nozzle_d) footprint();
                    offset(r=-2*panel_th) footprint();
                }
            }
        }
    }
    
    module orient() {
        if (print_orientation) {
            translate([panel_w, 0, panel_th/2]) rotate([0, 180, 0]) {
                children();
            }
        } else {
            children();
        }
    }

    text_h = 6;
    font = "Liberation Sans:style=bold";
    meter_size = metermod_size(panel_th);
    switch_size = rocker_size(panel_th);
    fuse_size = panel_fuse_size(panel_th);
    button_size = plasticbtn_size(panel_th);
    
    row_size =
        [switch_size.x + 2 + fuse_size.x + 2 + meter_size.x + 2 + button_size.x,
         max(switch_size.y, fuse_size.y, meter_size.y, button_size.y)];
    row_offset =
        [(panel_w - row_size.x) / 2,
         panel_h - (6 + row_size.y/2)];

    power_switch_pos =
        [row_offset.x + switch_size.x/2, row_offset.y];
    fuse_pos =
        [power_switch_pos.x + (switch_size.x + fuse_size.x)/2 + 2,
         power_switch_pos.y];
    battery_meter_pos =
        [fuse_pos.x + (fuse_size.x + meter_size.x)/2 + 2,
         fuse_pos.y];
    button_pos =
        [battery_meter_pos.x + (meter_size.x + button_size.x)/2 + 2,
         battery_meter_pos.y];
    battery_label_pos =
        [battery_meter_pos.x,
         battery_meter_pos.y - meter_size.y/2 - 1 - text_h];

    output1_meter_pos =
        [panel_w/4 - 1, battery_meter_pos.y - meter_size.y - 19];
    output2_meter_pos =
        [output1_meter_pos.x + panel_w/2 + 2, output1_meter_pos.y];
    output1_label_pos =
        [output1_meter_pos.x,
         output1_meter_pos.y + (meter_size.y/2 + 1)];
    output2_label_pos =
        [output2_meter_pos.x, output1_label_pos.y];
    
    orient() {
        difference() {
            union() {
                panel();
                translate(power_switch_pos)
                    rocker_support(panel_th, nozzle_d);
                translate(fuse_pos)
                    panel_fuse_support(panel_th, nozzle_d);
                translate(battery_meter_pos)
                    metermod_support(panel_th, nozzle_d);
                translate(output1_meter_pos)
                    metermod_support(panel_th, nozzle_d);
                translate(output2_meter_pos)
                    metermod_support(panel_th, nozzle_d);
                translate(button_pos)
                    plasticbtn_support(panel_th, nozzle_d);

                translate([0, 0, panel_th/2]) {
                    translate([2*panel_th, panel_h/2]) {
                        translate([17/2, 0]) rotate([0, 180, 0])
                            Wago221_holder(2);
                        translate([17/2+17-2, 0]) rotate([0, 180, 0])
                            Wago221_holder(2);
                    }
                    translate([button_pos.x+8, panel_h/2])
                        translate([-17/2, 0]) rotate([0, 180, 0])
                            Wago221_holder(2);
                    translate([panel_w/2, panel_h/2]) rotate([0, 180, 0])
                        Wago221_holder(5);
                    translate([panel_w/2, output1_meter_pos.y]) rotate([0, 180, 90])
                        Wago221_holder(3);
                }
            }
            translate(power_switch_pos)
                rocker_cutout(panel_th, nozzle_d);
            translate(fuse_pos)
                panel_fuse_cutout(panel_th, nozzle_d);
            translate(battery_meter_pos)
                metermod_cutout(panel_th, nozzle_d);
            translate(output1_meter_pos)
                metermod_cutout(panel_th, nozzle_d);
            translate(output2_meter_pos)
                metermod_cutout(panel_th, nozzle_d);
            translate(button_pos)
                plasticbtn_cutout(panel_th, nozzle_d);

            translate([0, 0, panel_th/4]) {
                linear_extrude(panel_th, convexity=10) {
                    translate(battery_label_pos)
                        text("BATTERY", text_h, font, halign="center",
                             spacing=1+(nozzle_d/text_h));
                    translate(output1_label_pos)
                        text("OUTPUT 1", text_h, font, halign="center");
                    translate(output2_label_pos)
                        text("OUTPUT 2", text_h, font, halign="center");
                }
            }
        }
    }
}

module walls(
    base_w=inch(5+1/8), base_h=inch(3+1/2), base_depth=inch(2),
    base_th=1.8, wall_th=1.8,
    print_orientation=false,
    nozzle_d=0.4
) {
    pg7_thread_d = 12;
    pg7_thread_pitch = 1.5;

    module footprint() {
        power_footprint(base_w, base_h, 5, nozzle_d=nozzle_d);
    }
    
    module gland() {
        // Horizontal hole for a screw-in PG5 gland.  Hole is
        // teardrop shaped for printability.
        h = wall_th;
        rotate([90, 0, 0]) translate([0, 0, -h]) {
            AT_threads(h+0.1, d=pg7_thread_d,
                       pitch=pg7_thread_pitch, tap=true,
                       nozzle_d=nozzle_d);
            linear_extrude(h+0.1) scale([6, 6])
                polygon([ [0, 2*cos(45)], [cos(45), sin(45)], [cos(135), sin(135)] ]);
        }
    }

    difference() {
        linear_extrude(base_depth, convexity=8) {
            difference() {
                footprint();
                offset(r=-wall_th) footprint();
            }
        }
        translate([0, 0, base_th+pg7_thread_d/2+3]) {
            translate([base_w/4, 0, 0]) gland();
            translate([base_w/4+base_w/2, 0, 0]) gland();
        }
    }
}

module base(
    base_w=inch(5+1/8), base_h=inch(3+1/2), base_depth=inch(2),
    base_th=1.8, wall_th=1.8,
    print_orientation=false,
    nozzle_d=0.4
) {
    module footprint() {
        power_footprint(base_w, base_h, 5, nozzle_d=nozzle_d);
    }
    
    function grommet_d(d, th, nozzle_d=0.4) =
        let(d0 = min(th, 3)) d + d0;        

    // A rounded hole for passing wires through without a sharp edge.
    module grommet(d, th, nozzle_d=0.4) {
        d0 = min(th, 3);
        lift = (th - d0) / 2;
        rotate_extrude(convexity=4, $fs=nozzle_d/2) {
            intersection() {
                translate([(d+d0)/2, 0]) hull() {
                    translate([0, -lift]) circle(d=d0, $fs=nozzle_d/2);
                    translate([0,  lift]) circle(d=d0, $fs=nozzle_d/2);
                }
                square([d+d0, th], center=true);
            }
        }
    }

    buck1_size = Tobsun_buck_size();
    buck1_pos =
        [2*wall_th + buck1_size.x/2 + 12,
         base_h - (2*wall_th + buck1_size.y/2 + 1)];
    buck1_rot = [0, 0, 180];

    buck2_size = LM2596_buck_size();
    buck2_pos =
        [base_w - (2*wall_th + buck2_size.x/2 + 6),
         base_h/2];
    buck2_rot = [0, 0, 90];

    difference() {
        union() {
            linear_extrude(base_th) {
                difference() {
                    footprint();
                    // Wire entry for battery adapter.
                    cut_d = grommet_d(3.5, base_th);
                    translate([inch(1/4), base_h/2]) {
                        translate([0, -15]) circle(d=cut_d, $fs=nozzle_d/2);
                        translate([0,  15]) circle(d=cut_d, $fs=nozzle_d/2);
                    }
                }
            }
            translate([0, 0, base_th]) translate(buck2_pos) rotate(buck2_rot)
                LM2596_buck_supports(nozzle_d=nozzle_d);
        }
        translate([0, 0, -2.5]) {
            linear_extrude(inch(0.5), convexity=8) {
                // Pilot holes for attaching Ridgid battery adapter plate.
                translate([base_w, base_h/2]) {
                    d = 2.7;  // tap size for #6
                    dy = 51.5 / 2;
                    translate([-19, -dy]) circle(d=d, $fs=nozzle_d/2);
                    translate([-19,  dy]) circle(d=d, $fs=nozzle_d/2);
                    translate([-50, -dy]) circle(d=d, $fs=nozzle_d/2);
                    translate([-50,  dy]) circle(d=d, $fs=nozzle_d/2);
                    translate([-108, -dy]) circle(d=d, $fs=nozzle_d/2);
                    translate([-108,  dy]) circle(d=d, $fs=nozzle_d/2);
                }
            }
        }
        translate([0, 0, base_th]) {
            translate(buck1_pos) rotate(buck1_rot) {
                Tobsun_buck_pilot_holes(nozzle_d=nozzle_d);
            }
            translate(buck2_pos) rotate(buck2_rot) {
                LM2596_buck_pilot_holes(nozzle_d=nozzle_d);
            }
        }
    }
    translate([inch(1/4), base_h/2, base_th/2]) {
        translate([0, -15]) grommet(3.5, base_th, nozzle_d);
        translate([0,  15]) grommet(3.5, base_th, nozzle_d);
    }
    
    Wago2_size = Wago221_holder_size(2);
    Wago3_size = Wago221_holder_size(3);
    translate([0, 0, base_th]) {
        translate([Wago2_size.x/2 + wall_th-1, 0]) {
            translate([0, base_h/2]) Wago221_holder(2);
            translate([0, base_h - 5 - Wago2_size.x/2]) Wago221_holder(2);
        }
        translate([0, Wago3_size.x/2 + wall_th-1, 0]) {
            translate([Wago3_size.y/2 + 5, 0])
                rotate([0, 0, 90]) Wago221_holder(3);
            translate([base_w - (Wago3_size.y/2 + 5), 0])
                rotate([0, 0, -90]) Wago221_holder(3);
        }

        translate([0, Wago2_size.x/2 + wall_th-1, 0]) {
            translate([base_w/2 - (Wago2_size.y/2 + 2), 0])
                rotate([0, 0, -90]) Wago221_holder(2);
            translate([base_w/2 + (Wago2_size.y/2 + 2), 0])
                rotate([0, 0, 90]) Wago221_holder(2);
        }

        translate([0, base_h - (Wago3_size.y/2 + wall_th + 2)]) {
            translate([buck1_pos.x + (buck1_size.x + Wago3_size.x)/2, 0]) {
                Wago221_holder(3);
                translate([Wago3_size.x - 2, 0]) Wago221_holder(3);
            }
        }

    }

    if (Show_Tobsun_Buck && $preview) {
        translate([0, 0, base_th]) {
            translate(buck1_pos) rotate(buck1_rot)
                Tobsun_buck(nozzle_d=nozzle_d);
        }
    }
    
    if (Show_LM2596_Buck && $preview) {
        translate([0, 0, base_th]) {
            translate(buck2_pos) rotate(buck2_rot)
                LM2596_buck(nozzle_d=nozzle_d);
        }
    }
}

if (Include_Base) {
    base(base_th=12, base_depth=Wall_Height, wall_th=2.2);
}

if (Include_Box_Walls) {
    walls(base_th=12, base_depth=Wall_Height, wall_th=2.2);
}

if (Include_Control_Panel) {
    z = (Include_Base || Include_Box_Walls) ? Wall_Height : 0;
    translate([0, 0, z])
        panel(panel_th=2.2, print_orientation=!$preview);
}

