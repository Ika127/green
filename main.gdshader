shader_type canvas_item;

void fragment() {
  float animation_speed = 1.0;  // Adjust animation speed if needed
  float repeat_interval = 1.0;  // Adjust repeat interval if needed
  
  float animated_time = abs(sin(TIME * animation_speed)) * repeat_interval;
  COLOR = vec4(UV, 0.5 * animated_time, 1.0);
}