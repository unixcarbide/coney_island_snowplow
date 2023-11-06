$fn = 512;

// what to render
ball = false;
pin = !ball;
carriage = !ball;

ball_d = 3;
ball_hertz = 0.03;
ogive_e = 1.2; // ogive overlap by radius
ogive_r = (ball_d / 2) * 1.4;

ball_offset = - ball_hertz -(ogive_r - (ball_d / 2)) * 0.7071;

pin_l = 30; // not actually used, bent pin is toroid arc segment selected by angle
pin_bend_r = 1000;

rail_l = 50;
rail_h = 20;
rail_gap = 0;

wing_x = 15;
wing_y = 15;
wing_z = 1.5;


module ogive() {
  union() {
    ogive_half();
    rotate([0, 0, 180])
    ogive_half();
  }
}

module ogive_half() {
  translate([0, (ogive_r * ogive_e) - ogive_r, 0])
  difference() {
    cube([rail_l, rail_h, rail_h], center=true);
    rotate([0, 90, 0])
    cylinder(r=ogive_r, h=rail_l+1, center=true);
    // cut top half off
    translate([0, 0, rail_h / 2])
    cube([rail_l+1, rail_h+1, rail_h], center=true);
    // cut further half off
    translate([0, rail_h/2 - (rail_gap/2) + (ogive_r - (ogive_r * ogive_e)), 0])
    cube([rail_l+1, rail_h, rail_h+1], center=true);
  }
}

module ball() {
  translate([0, 0, ball_offset])
  sphere(d=ball_d);
}

module ball_contact() {
  intersection() {
    ogive();
    ball();
  }
}

module pin() {
/*
  // straight pin
  rotate([0, 90, 0])
  cylinder(d=ball_d, h=pin_l, center=true);
*/

  // bent pin
  module half_bent_pin() {
    rotate([0, 90, 90])
    translate([-pin_bend_r, 0, 0])
    // this only does half, mirroring to do the other half
    rotate_extrude(angle = 1)
    translate([pin_bend_r, 0, 0])
    circle(d=ball_d);
  }

  // this only does half, mirroring to do the other half
  translate([0, 0, ball_offset])
  union() {
    half_bent_pin();
    mirror([1, 0, 0])
    half_bent_pin();
  }
}

module pin_contact() {
  intersection() {
    ogive();
    pin();
  }
}

module carriage() {

  module socket() {
    difference() {
      cylinder(d1 = 5, d2 = 3, h = 1.5);
      translate([0, 0, 1.6])
      sphere(d=3);
    }
  }

  module wing() {
    difference() {
      translate([0, 0, wing_z / 2])
      cube([wing_x, wing_y, wing_z], center = true);
      translate([0, 0, wing_z + 0.1])
      sphere(d=3);
    }
  }

  module fin() {
  }

  translate([0, 0, ball_d/2 + ball_offset]) 
  wing();
  

}

// somehow has to be at the top or everything turns red, and colour only works in preview...
color("red", alpha = 0.3) {
  if (ball == true) ball_contact();
  if (pin == true) pin_contact();
}

color("grey", alpha = 0.3) {
  ogive();
}

color("black", alpha = 0.3) {
  if (ball == true) ball();
  if (pin == true) pin();
}

if (pin == true && carriage == true) carriage();

/*
  // badly angled stone
  translate([0, -2.2, 11.1])
  rotate([60, 0, 0])
  cube([20, 20, 20], center = true);
*/
