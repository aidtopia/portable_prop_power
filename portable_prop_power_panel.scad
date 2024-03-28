// Portable Prop Power
// Adrian McCarthy 2024-03-14

// This is a project box for a DC power supply that supplies two outputs
// stepped down from a cordless tool battery.
//
// There are adapter plates available commercially for the batteries used
// by the various tools lines, like Dewalt, Ridgid, Ryobi, and many others.
// Depending on the brand, the battery packs nominally provide 18, 20, or
// 24V, which are available in high capacity sizes, like 4 amp-hours.  The
// packs include battery management circuitry, so we don't have to design
// our own charger.
// 
// For a Halloween prop, you often need a high amperage supply (e.g., to
// run a 12V wiper motor) and a lower voltage supply for the controller.
//
// The Portable Prop Power box is designed to attach to your cordless tool
// battery pack via an adapter plate bolted to the underside of the box.
// Inside, it houses two DC-DC step-down converters to provide the two
// supplies.  On top is a "control panel" with a power switch, a fuse, and
// three multimeter displays (one for the battery, and two for the outputs).
// There's also a pushbutton so that the displays are on only when needed.
//
// The exact buck modules and battery adapter plate will vary based on each
// haunters needs.  So those are attached to the "base" component, which
// can be customized without changing the control panel.  It's currently
// configured for a Ridgid battery adapter plate from Ecarke, a Tobsun
// 24V to 12V DC-DC apapter capable of 10 amps, and a generic HW-411 buck
// module based on an LM2596.  The base is quite thick to accommodate
// 1/2-inch screws for attaching the adapter plate to the bottom.  In
// practice, the base can be printed with a 0.3mm layer height ("Draft" in
// Pruse Slicer).  To save plastic, I reduced the infill to 10% which still
// seems sufficient.  
//
// The walls of the box are designed as a tube to which the base and control
// panel can be attached with M3x10mm screws.  This allows most of the wiring
// on the base and the back of the control panel to be completed without
// inside a deep box, to keep the base component customizable, and for speed
// of printing.  Two threaded openings for PG7 glands provide the outputs.
// Although these glands are advertised as "waterproof", the box itself is not.
// The wall unit can also be printed with 0.3mm layers ("Draft" in Prusa
// Slicer).
//
// The control panel must be printed with 0.2mm layers ("Quality" in Prusa
// Slicer) for good fit of the panel-mounted components.
//
// I used PETG, but PLA is probably fine as well.  The screw holes are
// pilot holes intended for M3x10mm machine screws.  If you anticipate
// opening and closing the box repeatedly, you might want to adjust the design
// to use heat-set threaded inserts.

Include_Base = true;
Include_Walls = true;
Wall_Height = 54; // [5:70]
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

// A rounded hole for passing wires through a panel without a sharp edge.
module rounded_hole(d, th, nozzle_d=0.4) {
    d0 = min(th, 3);
    lift = (th - d0) / 2 - 0.1;
    rotate_extrude(convexity=4, $fs=nozzle_d/2) {
        difference() {
            translate([0, -(th+1)/2]) square([(d+d0)/2, th+1]);
            translate([(d+d0)/2, 0]) hull() {
                translate([0, -lift]) circle(d=d0, $fs=nozzle_d/2);
                translate([0,  lift]) circle(d=d0, $fs=nozzle_d/2);
            }
        }
    }
}

module circular_hole_relief(r=undef, d=undef, max_span=3, overhang=45, layer_h=0.3) {
    radius = is_undef(r) ? d/2 : r;
    assert(0 < overhang && overhang < 90);
    if (overhang > 45) {
        echo("CAUTION: substantial overhang in circular_hole_relief.");
    }
    theta = 90 - overhang;

    // A chord cuts across the top of the circle where the overhangs
    // reach our limit.  This chord will be the base of the bridge.
    chord_y = radius*sin(90-theta);
    chord_l = radius*(cos(90-theta) - cos(90+theta));
    chord_x0 = -chord_l/2;
    chord_x1 =  chord_l/2;
    delta = tan(theta) * (chord_l - max_span)/2;
    
    // Above the nominal top of the circle will be a horizontal span
    // that must not be longer than max_span.
    span_y = max(chord_y + delta, radius + layer_h);
    dy = max(span_y - chord_y, 0);
    dx = dy / tan(theta);
    span_x0 = chord_x0 + dx;
    span_x1 = chord_x1 - dx;
    polygon([
        [chord_x0, chord_y],
        [span_x0, span_y],
        [span_x1, span_y],
        [chord_x1, chord_y]
    ]);
}

module gland(h, thread_d=12, thread_pitch=1.5, nut_d=20, nozzle_d=0.4) {
    // Horizontal hole for a screw-in PG7 gland.  Hole is
    // teardrop shaped for printability.
    rotate([90, 0, 0]) translate([0, 0, -(h+0.1)]) {
        AT_threads(h+0.2, d=thread_d, pitch=thread_pitch, tap=true,
                   nozzle_d=nozzle_d);
        linear_extrude(h+0.2, convexity=8)
            circular_hole_relief(d=thread_d);
    }
}

pg7_thread_d = 12;
pg7_thread_pitch = 1.5;
pg7_nut_d = 20;

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

module Wago221_holder(conductors=3, label="", nozzle_d=0.4) {
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
    box_h = 3.5;
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
            translate([0, -d/2, box_h]) {
                linear_extrude(h+th, convexity=8) {
                    square([lever_w, d], center=true);
                }
            }
            translate([0, d/2, 2*box_h]) {
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

    if (len(label) > 0) {
        font = "Liberation Sans:style=Bold";
        size = 4;
        linear_extrude(0.4) {
            translate([0, -((d+2*th)/2 + size + nozzle_d)])
                text(label, size, font, halign="center", valign="bottom",
                     $fs=nozzle_d/2);
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

    color("gray") translate([0, 0, 0.4]) {
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

module Tobsun_buck_supports(nozzle_d=0.4) {
    font = "Liberation Sans:style=Bold";
    linear_extrude(0.4, convexity=4) {
        difference() {
            square([50, 53], center=true);
            offset(delta=-2*nozzle_d) square([50, 53], center=true);
        }
        translate([0, -7.5]) {
            rotate([0, 0, 180])
                text("TOBSUN", 5, font, halign="center", valign="center",
                     spacing=1.05, $fs=nozzle_d/2);
            translate([-57/2, 0]) circle(d=5.5, $fs=nozzle_d/2);
            translate([ 57/2, 0]) circle(d=5.5, $fs=nozzle_d/2);
        }
    }
}

module Tobsun_buck_pilot_holes(nozzle_d=0.4) {
    dia = 2.5 + nozzle_d;  // tap size for M3
    translate([0, -7.5, -10]) {
        linear_extrude(10+1, convexity=4) {
            translate([-57/2, 0]) circle(d=dia, $fs=nozzle_d/2);
            translate([ 57/2, 0]) circle(d=dia, $fs=nozzle_d/2);
        }
    }
}

function LM2596_buck_size() = [43.5, 21.3];

module LM2596_buck(nozzle_d=0.4) {
    pcb_th = 1.6;
    translate([0, 0, 3]) {
        color("blue") linear_extrude(pcb_th) {
            difference() {
                square(LM2596_buck_size(), center=true);
                dx = 30/2; dy = 16/2;
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
    font = "Liberation Sans:style=Bold";
    dia = 5.5;
    linear_extrude(3, convexity=4) {
        dx = 30/2; dy = 16/2;
        translate([-dx,  dy]) circle(d=dia, $fs=nozzle_d/2);
        translate([ dx, -dy]) circle(d=dia, $fs=nozzle_d/2);
    }
    linear_extrude(0.4, convexity=6) {
        text("LM2596", 5, font, halign="center", valign="top",
             spacing=1.05, $fs=nozzle_d/2);
        text("→", 16, font, halign="center", valign="bottom",
             $fs=nozzle_d/2);
        dx = LM2596_buck_size().x/2; dy = LM2596_buck_size().y/2;
        translate([-dx, 0])
            text("IN", 3, font, halign="right", valign="center",
                 $fs=nozzle_d/2);
        translate([ dx, 0])
            text("OUT", 3, font, halign="left", valign="center",
                 $fs=nozzle_d/2);
        translate([-dx, -dy])
            text("−", 4, font, halign="right", valign="bottom",
                 $fs=nozzle_d/2);
        translate([-dx,  dy])
            text("+", 4, font, halign="right", valign="top",
                 $fs=nozzle_d/2);
        translate([ dx, -dy])
            text("−", 4, font, halign="left", valign="bottom",
                 $fs=nozzle_d/2);
        translate([ dx,  dy])
            text("+", 4, font, halign="left", valign="top",
                 $fs=nozzle_d/2);
    }
}

module LM2596_buck_pilot_holes(nozzle_d=0.4) {
    dia = 2.5 + nozzle_d;  // tap size for M3
    translate([0, 0, -10+3]) {
        linear_extrude(10.1, convexity=4) {
            dx = 30/2; dy = 16/2;
            translate([-dx,  dy]) circle(d=dia, $fs=nozzle_d/2);
            translate([ dx, -dy]) circle(d=dia, $fs=nozzle_d/2);
        }
    }
}

module portable_prop_power_box(nozzle_d=0.4) {
    box_w = inch(5+1/8);
    box_h = inch(3+1/2);
    corner_r = 4;
    panel_th = 2.2;
    base_th = 12;
    wall_th = 2.2;
    wall_h = Wall_Height;
    print_orientation = !$preview;

    m3_head_d = 6 + nozzle_d;
    m3_tap_d = 2.5;
    m3_free_d = 3.4 + nozzle_d;
    m3_head_h = 2.6;
    lip_h = min(m3_head_h + panel_th, base_th-1);

    Wago2_size = Wago221_holder_size(2);
    Wago3_size = Wago221_holder_size(3);
    Wago5_size = Wago221_holder_size(5);

    module box_footprint() {
        offset(r=corner_r, $fs=nozzle_d/2) offset(r=-corner_r)
            square([box_w, box_h]);
    }

    module corners(d) {
        dx = box_w/2 - corner_r;
        dy = box_h/2 - corner_r;
        translate([box_w/2, box_h/2]) {
            translate([-dx, -dy]) circle(d=d, $fs=nozzle_d/2);
            translate([-dx,  dy]) circle(d=d, $fs=nozzle_d/2);
            translate([ dx, -dy]) circle(d=d, $fs=nozzle_d/2);
            translate([ dx,  dy]) circle(d=d, $fs=nozzle_d/2);
        }
    }

    module support_footprint() {
        corners(d=2*corner_r);
    }
    
    module wall_footprint() {
        difference() {
            box_footprint();
            offset(r=-wall_th) box_footprint();
        }
        support_footprint();
    }

    module control_panel() {
        module panel() {
            linear_extrude(panel_th, center=true) box_footprint();
            translate([0, 0, -panel_th]) {
                linear_extrude(panel_th, center=true) {
                    difference() {
                        offset(r=-(2.2+nozzle_d/2)) box_footprint();
                        offset(r=-(2.2+nozzle_d/2)) offset(r=-2.2) box_footprint();
                        offset(r=nozzle_d/2) support_footprint();
                    }
                }
            }
        }
        
        module orient() {
            if (print_orientation) {
                translate([box_w, 0, panel_th/2]) rotate([0, 180, 0]) {
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
            [(box_w - row_size.x) / 2,
             box_h - (6 + row_size.y/2)];

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
            [box_w/4 - 1, battery_meter_pos.y - meter_size.y - 19];
        output2_meter_pos =
            [output1_meter_pos.x + box_w/2 + 2, output1_meter_pos.y];
        output1_label_pos =
            [output1_meter_pos.x,
             output1_meter_pos.y + (meter_size.y/2 + 1)];
        output2_label_pos =
            [output2_meter_pos.x, output1_label_pos.y];
        
        switched_power_pos = [box_w/2, box_h/2 + 1];
        meter_power_pos    =
            [switched_power_pos.x + Wago5_size.x/2 + Wago2_size.x/2-2,
             switched_power_pos.y];
        battery_neg_pos    =
            [switched_power_pos.x - (Wago5_size.x/2 + Wago2_size.x/2-2),
             switched_power_pos.y];
        battery_pos_pos    =
            [battery_neg_pos.x - (Wago2_size.x - 2),
             battery_neg_pos.y];
        return_power_pos   = [box_w/2 - 1, output1_meter_pos.y];

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
                        translate(switched_power_pos) rotate([0, 180, 0])
                            Wago221_holder(5);
                        translate(meter_power_pos) rotate([0, 180, 0])
                            Wago221_holder(2);
                        translate(battery_neg_pos) rotate([0, 180, 0])
                            Wago221_holder(2);
                        translate(battery_pos_pos) rotate([0, 180, 0])
                            Wago221_holder(2);
                        translate(return_power_pos) rotate([0, 180, 90])
                            Wago221_holder(3);
                    }
                }
                // screw holes
                linear_extrude(panel_th+1, center=true) corners(3.4+nozzle_d);

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

                translate([0, 0, -panel_th]) {
                    linear_extrude(panel_th, convexity=4, center=true) {
                        offset(r=nozzle_d/2) wall_footprint();
                    }
                }

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

    module walls() {
        module pg7_gland() {
            gland(wall_th, pg7_thread_d, pg7_thread_pitch, pg7_nut_d, nozzle_d);
        }

        dx = box_w/2 - corner_r;
        dy = box_h/2 - corner_r;
        screw_l = 10;
        screw_d = 2.5;  // tap diameter for M3

        difference() {
            linear_extrude(wall_h, convexity=4) {
                difference() {
                    wall_footprint();
                    translate([box_w/2, box_h/2]) {
                        translate([-dx, -dy]) circle(d=screw_d, $fs=nozzle_d/2);
                        translate([-dx,  dy]) circle(d=screw_d, $fs=nozzle_d/2);
                        translate([ dx, -dy]) circle(d=screw_d, $fs=nozzle_d/2);
                        translate([ dx,  dy]) circle(d=screw_d, $fs=nozzle_d/2);
                    }
                }
            }
            translate([0, 0, base_th+pg7_nut_d/2+3]) {
                translate([box_w/4, 0, 0]) pg7_gland();
                translate([box_w/4+box_w/2, 0, 0]) pg7_gland();
            }
        }
    }

    module base() {
        buck1_size = Tobsun_buck_size();
        buck1_pos =
            [2*wall_th + buck1_size.x/2 + 13,
             box_h - (2*wall_th + buck1_size.y/2)];
        buck1_rot = [0, 0, 180];

        buck2_size = LM2596_buck_size();
        buck2_pos =
            [buck1_pos.x + (buck1_size.x + buck2_size.y)/2+2,
             buck1_pos.y];
        buck2_rot = [0, 0, -90];

        battery_pos_pos =
            [wall_th + Wago2_size.y/2 + 1,
             box_h - (2*corner_r + Wago2_size.x/2 + nozzle_d)];
        battery_neg_pos =
            [battery_pos_pos.x, box_h/2];
        output1_pos_pos = 
            [2*corner_r + Wago3_size.y/2 + nozzle_d,
             Wago3_size.x/2 + wall_th + nozzle_d, 0];
        output2_pos_pos = 
            [box_w - output1_pos_pos.x,
             output1_pos_pos.y];
        output1_neg_pos =
            [box_w/2 - (Wago2_size.y/2 + 2),
             Wago2_size.x/2 + wall_th + nozzle_d, 0];
        output2_neg_pos =
            [box_w - output1_neg_pos.x,
             output1_neg_pos.y];
        return_power_pos =
            [box_w - (wall_th + Wago3_size.y/2 + 1),
             box_h/2 + Wago3_size.x];
        switched_power_pos =
            [return_power_pos.x,
             return_power_pos.y - Wago3_size.x];

        difference() {
            union() {
                difference() {
                    linear_extrude(base_th) box_footprint();
                    translate([inch(1/4), box_h/2, base_th/2]) {
                        translate([0, -15]) rounded_hole(3.5, base_th);
                        translate([0,  15]) rounded_hole(3.5, base_th);
                    }
                    translate([0, 0, lip_h]) {
                        linear_extrude(base_th, convexity=8) {
                            offset(r=nozzle_d/2) wall_footprint();
                        }
                    }
                }
                translate([0, 0, base_th]) {
                    translate(buck1_pos) rotate(buck1_rot)
                        Tobsun_buck_supports(nozzle_d=nozzle_d);
                    translate(buck2_pos) rotate(buck2_rot)
                        LM2596_buck_supports(nozzle_d=nozzle_d);
                }
                translate([0, 0, base_th]) {
                    translate(battery_pos_pos) rotate([0, 0, 90])
                        Wago221_holder(2, "BATT+");
                    translate(battery_neg_pos) rotate([0, 0, 90])
                        Wago221_holder(2, "BATT−");
                    translate(output1_pos_pos) rotate([0, 0,  90])
                        Wago221_holder(3, "OUT1+");
                    translate(output2_pos_pos) rotate([0, 0, -90])
                        Wago221_holder(3, "OUT2+");

                    translate(output1_neg_pos) rotate([0, 0, -90])
                        Wago221_holder(2, "OUT1−");
                    translate(output2_neg_pos) rotate([0, 0,  90])
                        Wago221_holder(2, "OUT2−");

                    translate(return_power_pos)   rotate([0, 0, -90])
                        Wago221_holder(3, "RETURN");
                    translate(switched_power_pos) rotate([0, 0, -90])
                        Wago221_holder(3, "SWPWR");
                }
            }

            // Screw holes for attaching to the walls.
            // We want recesses for the heads of the screws, but they
            // face bottom-up which makes it challenging to print.  For
            // slicing sanity, we leave one vertical layer of plastic
            // bridging the tapped portion of the hole.  It should be
            // easy to screw threw it.
            layer_h = 0.3;  // assumed
            translate([0, 0, -layer_h]) {
                linear_extrude(m3_head_h, convexity=4) corners(m3_head_d);
            }
            translate([0, 0, m3_head_h]) {
                linear_extrude(base_th+2, convexity=4) corners(m3_free_d);
            }

            translate([0, 0, -2.5]) {
                linear_extrude(inch(0.5), convexity=8) {
                    // Pilot holes for attaching Ridgid battery adapter plate.
                    translate([box_w, box_h/2]) {
                        d = 2.7;  // tap size for #6
                        dy = 51.5 / 2;
                        // Ecarke brand hole pattern:
                        translate([-19, -dy]) circle(d=d, $fs=nozzle_d/2);
                        translate([-19,  dy]) circle(d=d, $fs=nozzle_d/2);
                        translate([-50, -dy]) circle(d=d, $fs=nozzle_d/2);
                        translate([-50,  dy]) circle(d=d, $fs=nozzle_d/2);
                        translate([-108, -dy]) circle(d=d, $fs=nozzle_d/2);
                        translate([-108,  dy]) circle(d=d, $fs=nozzle_d/2);
                        // Anztek has the middle pair a different position:
                        translate([-56, -dy]) circle(d=d, $fs=nozzle_d/2);
                        translate([-56,  dy]) circle(d=d, $fs=nozzle_d/2);
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

    if (Include_Base) base();
    if (Include_Walls) {
        z = Include_Base ? lip_h : 0;
        translate([0, 0, z]) walls();
    }
    if (Include_Control_Panel) {
        z = (Include_Base || Include_Walls) ? lip_h + wall_h : 0;
        translate([0, 0, z]) control_panel();
    }
}

portable_prop_power_box();
