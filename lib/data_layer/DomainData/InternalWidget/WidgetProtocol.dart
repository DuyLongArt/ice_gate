// abstract class WidgetProtocol {
//   // Thuộc tính cốt lõi và bắt buộc
//   final String url;
//   final String imageUrl; // Ảnh
//   final String dateAdded; // Ngày thêm
//   final String widgetID;
//   final String host;
//   final String? name;
//   final int? port;
//   final String protocol;
//   // Thuộc tính IP Address TÙY CHỌN (Nullable String)
//   final String? ipAddress; // Ký hiệu '?' cho phép giá trị là null

//   // Constructor (Hàm tạo)
//   const WidgetProtocol({
//     required this.url,
//     required this.imageUrl,
//     required this.dateAdded,
//     required this.widgetID,
//     required this.host,
//     required this.protocol,
//     this.port,
//     this.name,
    
//     // Đặt ipAddress cuối cùng và không dùng 'required' để nó là tùy chọn
//     this.ipAddress, // Nếu không truyền, giá trị sẽ là null
//   });

//   // Phương thức trừu tượng
//   void connect();
//   String finalURL(){
//     return "${protocol}://${host}/${url}";
//   }
//   Future<bool> fetchData();
// }



