shader_type canvas_item;

void fragment() {
    // Lấy màu gốc của icon
    vec4 pixel_color = texture(TEXTURE, UV);

    // Tính khoảng cách từ điểm ảnh hiện tại đến tâm (0.5, 0.5)
    float dist = distance(UV, vec2(0.5));

    // Bán kính hình tròn là 0.5 (vừa khít khung hình vuông)
    float radius = 0.5;

    // Tạo mặt nạ hình tròn với mép mịn (anti-aliasing)
    // Nếu khoảng cách > bán kính thì độ trong suốt (alpha) về 0
    float circle_mask = 1.0 - smoothstep(radius - 0.005, radius + 0.005, dist);

    // Áp dụng mặt nạ vào alpha của ảnh
    pixel_color.a *= circle_mask;

    // Gán màu cuối cùng
    COLOR = pixel_color;
}