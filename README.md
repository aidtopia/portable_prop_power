# Portable Prop Power
Adrian McCarthy 2024

## Introduction

Many props require plugging in one or two DC power supplies.  This can be cumbersome.  But running props off of batteries (disposable alkaline or NiCd rechargeables) isn't feasible because they don't have enough capacity nor can they deliver the amperage necessary to power many props that move.

Lithium-ion and lithium-polymer batteries can store more energy and deliver higher power and often can be recharged quickly.  But they require careful battery management and are therefore difficult for DIY project.

Power banks are battery packs that provide power through a USB connection for devices that are normally charged or powered that way.  These can be very useful for simple electronics projects, but they generally don't have the capacity to power larger props for very long.

The battery packs for our cordless power tools are powerful, robust, and rechargeable.  Battery management is built right in.  And you probably already own some.

Unfortunately, each line of power tool battery packs have their own proprietary connections.  So getting at the power in a safe and reliable that doesn't require modifying the battery back would be a challenge.  But nowadays, buy adapters for most of the major brands (like Dewalt, Ridgid, Ryobi, and many others). The battery pack connects to the adapter in the same way it would connect to a power tool, and gives your project access to juice through a pair of wires.

Some of these adapters are available with fuse-protection, a power switch, a step-down converter, and even a multimeter display.  If that provides what you need, you're all set.

But I've found that many props require two supplies: 12V for the actuators and 5~9V for the controller electronics.  So I designed and assembled a portable dual-voltage DC power supply that can be powered directly from Ridgid cordless tool batteries.  My design should be adaptable to other battery brands by purchasing the appropriate adapter and modifying the design of the project box.

## Features

* 3D-printable project box connects directly to the battery just as a cordless tool would.
* Provides two DC outputs, typically 12V up to 10 amps, and 5V up to 3 amps.
* Fuse provides protection against drawing too much current.
* Switch lets you turn off the power without physically disconneting the battery.
* Three pushbutton-activated multimeter displays let you check the voltage and current draw of the two supplies and the battery.
* Assembly requires almost no soldering.  Connections are made with lever nuts and screw terminals.  Some crimp-on ferrules and other wire terminals are recommended.

## Electrical Design Notes

The Ridgid tool batteries I have provide 18V.  Other brands offer 20V or even 24V.  The DC-DC converters I've selected are designed for voltages in this range.  If your batteries provide more than 24V, you'll have to select different step-down converters.  Do not power the multimeters with more than 30V.

The positive terminal from the battery is connected through a fuse to a power switch.

The battery power on the other side of the switch is the "switched power," which is distributed to the two voltage converters.

The voltage converters are off-the-shelf modules.  In my default configuration, one is a Tobsun 24V-to-12V step-down buck converter that can provide up to 10 amps to the load, and the other is an HW-411 buck converter based on the LM2596 chip that provides an adjustable output voltage and delivers up to 3 amps.

The switched power is also routed to the multimeters through a momentary pushbutton switch.  I chose to have the meters off by default.  Although the meters are low power, over time that could add up.  Also, they meters are illuminated, and I wanted the supply to be dark when in use in a haunt.

## Parts

### Battery Adapter

Without the right search terms, these can be tricky to find.  Start with the brand name of your batteries (e.g., "Ridgid") and add "Power Wheels adapter".  Power Wheels are toy cars for kids, which many people modify to power from cordless tool battery packs.  You might also try searching for "robotics" as these adapters are often used for DIY robots.

I purchased a couple from Ecarke and Anztek via Amazon for less than $15 each.  They are virtually identical except for the placement of some of the mounting holes.  My 3D box design accommodates either pattern.

Some of these adapters come with an inline fuse and/or an inline power switch.  Those are fine, but since our supply will provide both of those features, they're unnecessary.

The adapters should have wires that are between 18 and 12 AWG.

Example: https://www.amazon.com/dp/B0913H7WBP

### Fuse Holder with 10 amp fuse

My project box is designed to use a 12-mm diameter panel-mount fuse holder that holds 5x20 mm glass fuses.  If you prefer a different type, you'll have to modify the box design.

Example: https://www.amazon.com/gp/product/B0BF9LDW1P

The ones I purchased came with leads pre-soldered to the terminals.  You can also purchase them without leads and solder your own on if you like.

Fuse protection is important.  Tool batteries can source a lot of current.  A wiring fault, could cause the battery to quickly overheat and catch fire.  The batteries probably have some protection built in, but it may not be sufficient.  Even if the built-in protection is designed to disconnect the battery when there's a high current, it's trigger level may be much higher than 10 amps, but some of the other parts in the project are rated up to 10 amps.

The wiper motors commonly used in Halloween props draw up to do almost 5 amps in normal use.  When a motor is turned on, there can be a brief high-current spike called in-rush current, so a 5-amp fuse would be too low.

### Power Switch

I used a panel-mount rocker switch rated for 10 amps.  It has quick-disconnect tabs, so I chose to crimp spade terminals to the connecting wires, which avoids soldering.  If you don't have the right crimping tool or connectors, you might be able to purchase them with pre-terminate leads.  As a last resort, you can solder wires directly, though be aware that makes it harder to take the project apart to fix it or replace parts.

Example: https://www.amazon.com/dp/B07S2QJKTX

### Push Button

The panel meters are powered only while you press the push button.  I used a 12 mm panel-mount plastic button.  The button controls the battery voltage at very low current, so the exact specs are unimportant.  I got these without leads and soldered my own wires onto them.

Example: https://www.amazon.com/dp/B07F24Y1TB

### Multimeter Displays

I used three snap-in panel-mount multimeter modules that display both the voltage and current draw (amps).

Example: https://www.amazon.com/gp/product/B08HQM1RMF/

Each one comes with two cable bundles that plug into connectors on the back of the module.

1. Three thin wires (red, black, yellow) crimped to a JST XH 3-pin female connector.  This provides the power for the meter itself (red), the voltage to be measured (yellow), and--depending on whether the meter is powered independently, the ground connection (black).  To wire the project neatly, you'll have to modify these wires.  If you need a replacement: https://www.amazon.com/dp/B07FBHKY8G

2.  Two thick wires (red, black) crimped to a JST VH 3.96mm 2-pin female connector.  This routes the return current from your circuit through the meter for measuring the amps.  I was unable to find exact replacements (and I'm not thrilled about the redundant wire colors), so I picked up a JST VH crimping kit to make my own:  https://www.amazon.com/dp/B089QRPTYS

### DC-DC Voltage Converters

I used two buck (i.e., step-down) converters.

#### Tobsun 24-12V, 10A Step-Down Converter

Specifically: https://www.amazon.com/dp/B0CP4VH52L

There are several other converters with similar specs.

Example:  https://www.amazon.com/dp/B0C66635R1

That should work fine, but I haven't tested it yet.  It's footprint is larger, but it should be possible to squeeze it into the existing box.

#### LM2596 Adjustable DC-DC Step-Down Converter

These are actually modules based on the LM2596 chip.  The modules are sometimes given the model number HW-411.

Example: https://www.amazon.com/dp/B07PDGG84B

You will have to solder wires to the input and output pads.

### Wago 221-Series Lever Nuts

Although they're a bit overkill and add quite a bit of bulk to the project, these simplified most of the hook-up.

The design requires:

* 7 2-conductor connectors
* 5 3-conductor connectors
* 1 5-conductor connector

### Hook-up Wire

Most of the connections require 18 AWG (or thicker) stranded wire.  There are many connections in a tight volume, so the extra flexibility of silicone-insulated wire is desirable but not essential.  An assortment of colors is also helpful.

Example: https://www.amazon.com/dp/B08FMDBV2Z

The 18 AWG will not fit into the through-holes on the LM2596 module, but 20 AWG wire will.  Since that module handles only 3 amps, the thinner gauge is acceptable here.

The pushbutton for the meter power can also be connected with thinner wires because very little current flows through that path.  A little bit a heat-shrink tubing is useful to insulate the solder joints on the pushbutton.

Heat shrink can also be a good way to label wires, especially if you don't have a range of colors to use.

### Crimp Terminals

I mostly used insulated crimp-on ferrules (from an assortment of sizes needed), some spade terminals (sized for the wire gauge and the tabs on the rocker switch), and some fork terminals (sized for the wire gauge the M3 screws on the buck converter).

* 12 AWG:  These thick wires from the battery adapter plate are terminated directly into the Wago lever nuts without any crimp connectors.

* 18 AWG and 20 AWG:  These hookup wires can be held securely by the Wago lever nuts, but I put ferrules on most them and inserted the ferrule into the lever nuts to keep things tidy, especially as I was prototyping.  Exceptions:

    * One wire from the fuse holder was terminated with a crimp-on spade connector that fits the terminals on the rocker switch.  The alternative is the solder that lead to a rocker switch terminal, after the two parts are inserted into the control panel.
    
    * Wire ends that connect to the screw terminals on the Tobsun buck converter were terminated with crimp-on fork connectors that matched the wire gauge and the screw size (M3).  The alternative is to crimp on ferrules.

* The 26 AWG wires (in the 3-wire cable assembly for the multimeters) are too fine to be held by the lever nuts, so I crimped ferrules onto them before inserting them into the lever nuts.

    * Red:  These need to be bonded together, so I twisted the stripped ends together and crimped them into a single ferrule.
    
    * Black:  The two for the output meters need to be bonded together, so I combined those into a single ferrule.  (The remaining black wire is not connected and can just be cut short.)
    
    * Yellow:  Each of these must be crimped into their own ferrule, but the 26 AWG wire is thinner than my ferrule assortment.  I worked around this by stripping those wires about twice as far as normal, folding the stripped wire back onto itself and twisting it together. This gave it enough bulk for my 22 AWG ferrules to hold securely.

### Glands

Two PG7 glands with strain relief are used to secure the output wires to the side of the project box.

Example: https://www.amazon.com/gp/product/B09W9P2QJ8

### Output Connections

I use pre-wired DC barrel connectors.

Example: https://www.amazon.com/gp/product/B072BXB2Y8

Note that these are rated for only 5 amps, which is fine for the low current output.  Power for wiper motors should use a more substantial connector.

### Project Box

I designed a custom project box to be 3D printed.