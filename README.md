Tugas 8
1. Jelaskan perbedaan antara Navigator.push() dan Navigator.pushReplacement() pada Flutter. Dalam kasus apa sebaiknya masing-masing digunakan pada aplikasi Football Shop kamu?

Navigator.push itu akan membuka halaman baru diatas halaman saat ini ( menambah ke tumpukan stack navigasi). Navigator.pushReplacement nanti akan mengganti halaman saat ini dengan halaman baru (menghapus halaman sebelumnya dari stack).

Jadi navigator.push kalau posisi di stack nantinya halaman lama tersimpan di bawah, kalau di navigator.pushreplacement nanti halaman lama dihapus kemudian halaman baru akan menggantikan posisinya. Kegunaan untuk navigator push sangat cocok untuk navigasi antar halaman biasa, sedangkan kalau navigator.pushreplacement lebih cocok untuk navigasi yang bersifat "permanen"

Contoh kegunannya di aplikasi football shop punya saya pada saat dari halaman utama ke halaman create product: 
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const NewsFormPage()),
);
setelah menekan tombol back, pengguna bisa kembali ke halaman utama. 

Untuk dalam program saya contoh bagian navigator.pushReplacement: 
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const MyHomePage()),
);
jadi nanti pengguna menekan tombol back, dia kembali ke login karena sudah diganti oleh halaman utama


2. Bagaimana kamu memanfaatkan hierarchy widget seperti Scaffold, AppBar, dan Drawer untuk membangun struktur halaman yang konsisten di seluruh aplikasi?
Aplikasi Flutter  (PAT SHOP) menggunakan struktur hierarki widget yang rapi untuk menjaga konsistensi antar halaman. Strukturnya seperti ini: 
MaterialApp
 └── Scaffold
       ├── AppBar
       ├── Drawer
       └── Body (isi halaman)

Dalam hal ini saya menerapkan pada: 
return Scaffold(
  appBar: AppBar(
    title: const Text('Add Product Form'),
  ),
  drawer: const LeftDrawer(),
  body: Form(...),
);

Dengan hierarki seperti ini, maka:
-Semua halaman punya AppBar dan Drawer yang sama.
-Aplikasi terlihat konsisten, rapi, dan mudah digunakan.
-Bisa membuat satu widget Drawer (LeftDrawer) lalu pakai ulang di semua halaman sehingga akan efisien dan modular.


3. Dalam konteks desain antarmuka, apa kelebihan menggunakan layout widget seperti Padding, SingleChildScrollView, dan ListView saat menampilkan elemen-elemen form? Berikan contoh penggunaannya dari aplikasi kamu.

-Dalam konteks punya saya, Padding berfungsi untuk memberi jarak antar elemen agar tidak saling menempel dan membuat tampilan lebih rapi dan mudah dibaca. Saya ada menerapkan padding di aplikasi saya seperti berikut : 

Padding(
  padding: const EdgeInsets.all(8.0),
  child: TextFormField(...),
),

Dalam kode saya padding ini berfungsi untuk mempunyai jarka 8 pixel di semua sisi setiap TextFromField. 

-SingleChildScrollView 
Berfungsi untuk membuat halaman bisa dilakukan scroll kalau kontennya panjang, misalnya form yang mempunyai banyak input. Jika tidak menggunakan ini, form akan bisa error overflow di layar kecil . Berikut penerapan di kode saya: 

body: Form(
  key: _formKey,
  child: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [...],
    ),
  ),
),

Pada potongan kode diatas memberikan arti bahwa pengguna tetap bissa melihat tombol "Simpan" meskipun formnya panjang, karena halaman bisa digulir ke bawah 

-List View
List view berguna ketika kita ingin menampilkan banyak item dinamis (contoh: daftar produk). Hal ini sangat mirip column, tetapi otomati sbisa scroll tanpa perlu SingleChildScrollView. Berikut penerapan pada kode saya : 

return Drawer(
  child: ListView(
    children: [
      DrawerHeader(...),
      ListTile(...),
      ListTile(...),
    ],
  ),
);

Kegunaan listview disini untuk Listview bisa otomatis scroll kalau menu di Drawer makin banyak. Selain itu, tidak perlu juga SingleChildScrollView tambahan.


4.Bagaimana kamu menyesuaikan warna tema agar aplikasi Football Shop memiliki identitas visual yang konsisten dengan brand toko?

Dalam penyesuaian menerapkan tema di aplikasi saya , saya menerapkan warna tema global di main.dart: 

theme: ThemeData(
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
      .copyWith(secondary: Colors.blueAccent[400]),
),

Warna tersebut juga akan saya gunakan secara konsisten di seluruh halmaan baik di appbar, drawer header, tombol utama, form button (simpan).

Kode menu.dart, saya juga gunakan untuk menunjukkan penerapan warna tema dengan cara manual yang konsisten pada halaman MyHomePage. Berikut penerapannya: 

appBar: AppBar(
  title: const Text(
    'PAT SHOP',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  backgroundColor: Colors.blueAccent, // warna utama brand
),

warna blueAccent di AppBar sama dengan primarySwatch di tema utama, jadi halaman Home tetap terasa satu brand dengan halmaan lain seperti Add Product. 

Selain itu pada tombol-tombol saya juga ada memberikan warna seperti berikut : 

final List<ItemHomepage> items = const [
  ItemHomepage("All Products", Icons.list, Colors.blue),
  ItemHomepage("My Products", Icons.shopping_bag, Colors.green),
  ItemHomepage("Create Product", Icons.add, Colors.red),
];
Jadi saya memberikan perbedaan visual antar fitur dengan biru untuk fitur AllProduct , hijau untuk fitur My Products dan Merah untuk fitur Create Product.

Saya juga menerapkan tema di tombol interaktif dengan menerapkan hal berikut: 

style: ElevatedButton.styleFrom(
  backgroundColor: item.color,
  minimumSize: const Size(220, 50),
),

Hal ini berfungsi untuk menjaga agar semua tombol punya ukuran dan gaya yang konsisten, walaupun warnanya berbeda. 



---------------------------------------------------------------------------------------------------------------------------------
Tugas 7

Jelaskan apa itu widget tree pada Flutter dan bagaimana hubungan parent-child (induk-anak) bekerja antar widget.
widget tree adalah struktur hierarki (seperti pohon) dan menunjukkan bagaimana widget-widget saling berhubungan dan tersusun dalam aplikasi. Setiap widget bisa berisi widget lain di dalamnya dan itulah sering disebut hubungan parent child. Contohnya : MaterialApp( home: Scaffold( appBar: AppBar(title: Text("PAT SHOP")), body: Center( child: ElevatedButton( onPressed: () {}, child: Text("All Products"), ), ), ), )

maka nanti akan dibuat strukturnya seperti pohon kayak dibawah ini

MaterialApp └── Scaffold ├── AppBar │ └── Text("PAT SHOP") └── Center └── ElevatedButton └── Text("All Products") Artinya: -MaterialApp adalah induk utama (root). -Di dalamnya ada anak (Scaffold), lalu anak dari anak (AppBar, Center, dst).

Hubungan parent–child ini sangat penting karena parent mengatur tata letak dan konteks anaknya,child mewarisi properti tertentu (seperti tema, warna, atau alignment) dari parent.

Sebutkan semua widget yang kamu gunakan dalam proyek ini dan jelaskan fungsinya.
Widget yang saya gunakan ada 11 yaitu

MaterialApp berfungsi untuk membungkus seluruh aplikasi Flutter, menyediakan tema, navigasi, dan pengaturan umum. -Scaffold berfungsi untuk menyediakan struktur dasar halaman (AppBar, body, floatingActionButton, dll). -AppBar berfungsi untuk bagian header di atas layar, menampilkan judul “PAT SHOP”. -Text berfungsi untuk menampilkan tulisan (misal: judul dan teks di tombol). -Padding berfungsi untuk memberi jarak di sekitar widget biar tampilannya rapi. -Center berfungsi untuk meletakkan widget anaknya di tengah layar. -Column berfungsi untuk menyusun widget secara vertikal (atas ke bawah). -ElevatedButton.icon berfungsi untuk membuat tombol dengan teks dan ikon di dalamnya. -SnackBar berfungsi untuk menampilkan pesan singkat di bawah layar ketika tombol ditekan. -Icon berfungsi untuk menampilkan ikon pada tombol (misalnya Icons.list, Icons.add). -ScaffoldMessenger berfungsi untuk mengatur tampilan dan penghapusan SnackBar.
Apa fungsi dari widget MaterialApp? Jelaskan mengapa widget ini sering digunakan sebagai widget root.
Widget MaterialApp sering disebut sebagai pintu masuk utama aplikasi flutter yang menggunakan desain material design dari google. Widget materialapp berfungsi untuk mengatur tema warna (pakai colorscheme), menentukan halaman awal lewat properti home, mengatur navigasi antar halaman (routes, navigator), serta menyediakan material design berupa tombol,Appbar,snackbar,dll. Dengan fungsi yang banyak ini membuat Materiall menjadi root karena tanpa dia maka widget seperti Scaffold, AppBar, ElevatedButton, atau SnackBar tidak bisa digunakan, sebab semuanya membutuhkan konteks Material Design yang disediakan oleh MaterialApp.

Jelaskan perbedaan antara StatelessWidget dan StatefulWidget. Kapan kamu memilih salah satunya? statelesswidget itu biasanya tidak punya state (data yang bisa dirubah) sehingga jika sekali dibangun maka tampilannya tidak akan berubah kecuali direbuild semuanya. StatefullWidget itu mempunyai state internal yang bisa berubah (input,animasi,dll) serta bisa memanggil setState() untuk memperbarui tampilan.
StatelessWidget biasa dipakai untuk tampilan statis seperti teks,tombol, logo dan header. Sedangkan untuk statefulwidget digunakan kalau kita membutuhkan perubahan dinamis , misal form,animasi atau data dari API. Dalam tugas ini saya menggunakan stateless widget karena tombool saya tidak berubah tampilan saat ditekan.

Apa itu BuildContext dan mengapa penting di Flutter? Bagaimana penggunaannya di metode build?
BuildContext adalah objek yang menyimpan informasi mengenai posisi suatu widget di dalam widget tree.Setiap build() dijalankan, flutter akan memberikan BuildContext untuk memberitahu bahwa dimana posisi widget itu berada, siapa parentnya serta apa saja yang diwarisi dari atas.

biasa seperti: Widget build(BuildContext context) { return Scaffold( appBar: AppBar( title: Text('PAT SHOP'), ), ); }

context disini sangat berperan penting untuk mengakses theme.off (context) (warna tema), akses navigator.of (context) (pindah halaman), akses scaffoldmessenger.of(context) (snackbar). Tanpa context, maka flutter tidak tahu widget ini sedang dimana di treenya

Contoh penggunaan BuildContext:

onPressed: () { ScaffoldMessenger.of(context) ..hideCurrentSnackBar() ..showSnackBar( SnackBar( content: Text("Kamu telah menekan tombol ${item.name}"), ), ); }

ScaffoldMessenger.of(context) nantinya flutter akan mencari widget Scaffold terdekat di atas tombol. Karena tombol itu ada di dalam Scaffold, maka flutter tahu di mana harus menampilkan SnackBar-nya. Jadi tanpa BuildContext, Flutter tidak akan tahu Snackbar itu harus muncul di layar mana.

Jelaskan konsep "hot reload" di Flutter dan bagaimana bedanya dengan "hot restart".
Hot reload konsepnya adalah menyuntikkan perubahan kode ke aplikasi tanpa harus kehilangan state (misal data di layar tidak di reset), Hot restart konsepnya adalah merestart aplikasi dari awal dan membangun ulang widget tree. Selain itu, semua statenya akan hilang .

Efek dari hot reload akan sangat cepat dan cocok untuk ubah UI atau logika kecil, sedangkan untuk hot restart akan lebih lambar tapi bersih karena cocok untuk ubah kode besar seperti main atau insialisasi global.