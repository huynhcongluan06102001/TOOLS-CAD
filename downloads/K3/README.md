# K3 standalone 0.1 — bản thử nghiệm, AutoCAD Windows

Đây là triển khai độc lập từ mô tả thao tác; không phải mã nguồn DOMI và chưa có đầy đủ khả năng như video. Không sửa TOOLS-CAD.

Đã đọc TEMPLATE CAD HL1.dwg: 499 MLINE hai đỉnh, 1867 INSERT, nhiều ELB45, TEE, Y và các khu vực chi tiết/thư viện khác nhau. Không xử lý toàn bản vẽ một lượt. Mô hình giải giữ phương vector từng đoạn, giữ nhóm đầu ống trong một block phụ kiện dịch chuyển cứng, cố định đầu hở không được chọn kéo. Tìm nghiệm có tổng bình phương dịch chuyển nhỏ nhất. Mâu thuẫn ràng buộc, đoạn đảo chiều hoặc quá ngắn sẽ bị từ chối trước khi sửa.

## Sử dụng trên bản sao DWG

1. APPLOAD K3.lsp. Gõ HLK3. K3 cũng được đăng ký nếu tên lệnh đó chưa bị LISP khác dùng.
2. Chọn TOÀN BỘ mạng cục bộ cần xét: các MLINE/LINE và co, tê, Y liên quan, gồm cả các đoạn nối tới đầu neo cố định. Tối đa 100 đối tượng.
3. Nhập sai số nhận đầu nối, mặc định 0.1 đơn vị bản vẽ. Không tăng sai số lớn để ép ghép các tuyến khác nhau.
4. Chọn các ống/phụ kiện thuộc cụm cần TRƯỢT, phải nằm trong tập đã chọn bước 2.
5. Chọn hai điểm xác định vector dịch chuyển. Đường tim kết quả dự kiến hiện màu xanh. Xem kỹ các nhánh và vị trí neo.
6. Gõ Yes để áp dụng; Enter/No bỏ qua. Sau khi áp dụng, U hoàn tác cả lượt.

Để trượt ngang một tuyến đứng: chọn tuyến đứng và các phụ kiện của nó ở bước 4; các nhánh ngang trong mạng sẽ thay đổi chiều dài. Đầu hở ngoài cụm kéo cố định. Mạng có vòng kín/góc không tương thích có thể không có nghiệm cho vector đã chọn; khi đó cần đổi vector hoặc phạm vi cụm.

## Giới hạn cần biết

- Chỉ MLINE thẳng hai đỉnh, căn tim Zero và LINE trên XY/Z=0; giữ style, size và layer. Không co giãn block tuyến ống gió/thang máng trong bản này.
- Block phụ kiện được giới hạn tên ELB*, TEE*, Y-*, RED*, SCREW-*, WELD-*. Không chọn block thiết bị/ký hiệu, Xref, khung bản vẽ.
- Nhận các đầu ống thuộc phụ kiện bằng hộp bao block và sai số trong phạm vi bạn đã chọn. Đây là phép suy đoán hình học, CHƯA phải hệ quản lý connector đầy đủ. Hai block cùng bao một đầu hoặc số đầu không nằm trong 2–4 sẽ bị từ chối. Block có hình ẩn/attribute làm hộp bao lớn, ống không liên quan nằm trong hộp bao hoặc thiếu đối tượng ở tập chọn có thể gây nhận sai; phải xem kết quả trên bản sao trước.
- Chỉ giữ hướng và liên kết theo mô hình đã nhận; chưa kiểm tra va chạm giữa các phụ kiện, chưa tự dời ghi chú, chưa trượt côn dọc tuyến, chưa dựng lại co/tê hoặc đổi visibility. Phụ kiện giữ rotation/scale/state, chỉ tịnh tiến.
- Chưa có preview liên tục theo con trỏ. Có xem trước đường tim sau khi chọn vector và trước khi bấm Yes.
- Kết nối dạng nhánh chạm giữa thân MLINE nhưng không có nút/đầu đoạn hoặc block phụ kiện không được tự phát hiện.
- Đã chạy 52 kiểm tra bộ giải vector bằng VeLisp và kiểm tra ngoặc. CHƯA kiểm thử COM/UNDO, độ nhận đúng cổng block hoặc thao tác trên AutoCAD 2025. Không coi đây là bản sản xuất đã được xác nhận.

## Kiểm tra đề nghị

Thử một tuyến chữ U đơn giản trước: kéo đoạn ngang lên, hai đầu dưới giữ nguyên; U phục hồi. Sau đó thử một tê và hai nhánh, Y 45°, chọn sai vector để kiểm tra từ chối. Đối chiếu màu/style/size, tọa độ các đầu nối và block trước–sau. Giữ lại DWG thử nếu có kết quả sai để điều chỉnh thuật toán nhận cổng.
