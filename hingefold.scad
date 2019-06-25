//
// A click-together joint, intended to hold together the two sides of a living hinge
//
// parameters:
//   size:       the height and depth of the pegs
//   width:      the width of the pegs
//   thickness:  thickness of the panel on which the joint will sit
//   offset:     allows for additional lateral displacement to move the joint away from the hinge (NB: affects height)
//   plug:       whether to include the male (single post) plug
//   socket:     whether to include the female (double post) socket
//   reverse:    whether to reverse the relative position of plug and socket
//

module HingeJoint(size = 3.2, width = 2.0, thickness = 1.2, offset = 0, plug = true, socket = true, reverse = false) {

	// for avoiding coincident planes
	eps = 0.001;

	// base component, centered on origin, sat on Z plane
	module _plug() {
		translate([-width / 2, -eps, -eps]) scale([width, size + 2 * eps, size + offset + 2 * eps]) cube();
		translate([0, size / 2, offset + size / 2]) sphere(d = width + 0.6, $fs = 0.1);
	}

	// base component, centered on origin, sat on Z plane
	module _socket() {
		difference() {
			translate([-3 * width / 2, 0, 0]) scale([3 * width, size - eps, size + offset - eps]) cube();
			_plug();
		}
	};

	// plug component moved away from the joint
	module Plug() {
		translate([0, thickness + offset, thickness]) _plug();
	}

	// socket component moved away from the joint in the opposite direction
	module Socket() {
		rotate([0, 0, 180]) {
			translate([0, thickness + offset, thickness]) _socket();
		}
	}
 
	rotate([0, 0, reverse ? 0 : 180]) {
		if (plug) {
			Plug();
		}
		if (socket) {
			Socket();
		}
	}
};

//
// A wedge shaped piece oriented along the X axis and centered on the origin,
// intended to be subtracted from other parts to allow a fold to be made along it.
//
// parameters:
//	 width:      the total width of the cut
//	 thickness:  thickness of the panel through which the cut will be made
//	 fold:       how much material to leave at the point of the fold
//

module HingeCut(width = 10, thickness = 1.2, fold = 0.2) {

	// for avoiding coincident planes
	eps = 0.001;
	
	translate([-width / 2, 0, 0])
	rotate([90, 0, 90])
	linear_extrude(height = width)
	polygon([
		[fold, fold],
		[thickness, thickness + eps],
		[-thickness, thickness + eps],
		[-fold, fold]
	]);
};

module _HingeTest(offset = 0, fold = 0.2) {
	t = 1.2;
	difference() {
		union() {
			translate([-4, -10, 0]) cube([8, 20, t]);
			HingeJoint(thickness = t, offset = offset);
		}
		HingeCut(thickness = t, fold = fold);
	}
}

translate([0, 0, 0]) _HingeTest();
