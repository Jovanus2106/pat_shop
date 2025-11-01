Tugas 7 
1. Jelaskan apa itu widget tree pada Flutter dan bagaimana hubungan parent-child (induk-anak) bekerja antar widget. 

widget tree adalah struktur hierarki (seperti pohon) dan menunjukkan bagaimana widget-widget saling berhubungan dan tersusun dalam aplikasi. Setiap widget bisa berisi widget lain di dalamnya dan itulah sering disebut hubungan parent child. Contohnya : 
MaterialApp(
  home: Scaffold(
    appBar: AppBar(title: Text("PAT SHOP")),
    body: Center(
      child: ElevatedButton(
        onPressed: () {},
        child: Text("All Products"),
      ),
    ),
  ),
)

maka nanti akan dibuat strukturnya seperti pohon kayak dibawah ini 

MaterialApp
 └── Scaffold
      ├── AppBar
      │     └── Text("PAT SHOP")
      └── Center
            └── ElevatedButton
                  └── Text("All Products")
Artinya:
-MaterialApp adalah induk utama (root).
-Di dalamnya ada anak (Scaffold), lalu anak dari anak (AppBar, Center, dst).

Hubungan parent–child ini sangat penting karena parent mengatur tata letak dan konteks anaknya,child mewarisi properti tertentu (seperti tema, warna, atau alignment) dari parent.

2. Sebutkan semua widget yang kamu gunakan dalam proyek ini dan jelaskan fungsinya. 

Widget yang saya gunakan ada 11 yaitu
- MaterialApp berfungsi untuk membungkus seluruh aplikasi Flutter, menyediakan tema, navigasi, dan pengaturan umum.
-Scaffold berfungsi untuk menyediakan struktur dasar halaman (AppBar, body, floatingActionButton, dll).
-AppBar berfungsi untuk bagian header di atas layar, menampilkan judul “PAT SHOP”.
-Text berfungsi untuk menampilkan tulisan (misal: judul dan teks di tombol).
-Padding berfungsi untuk memberi jarak di sekitar widget biar tampilannya rapi.
-Center berfungsi untuk meletakkan widget anaknya di tengah layar.
-Column berfungsi untuk menyusun widget secara vertikal (atas ke bawah).
-ElevatedButton.icon berfungsi untuk membuat tombol dengan teks dan ikon di dalamnya.
-SnackBar berfungsi untuk menampilkan pesan singkat di bawah layar ketika tombol ditekan.
-Icon berfungsi untuk menampilkan ikon pada tombol (misalnya Icons.list, Icons.add).
-ScaffoldMessenger berfungsi untuk mengatur tampilan dan penghapusan SnackBar.

3. Apa fungsi dari widget MaterialApp? Jelaskan mengapa widget ini sering digunakan sebagai widget root. 

Widget MaterialApp sering disebut sebagai pintu masuk utama aplikasi flutter yang menggunakan desain material design dari google. Widget materialapp berfungsi untuk mengatur tema warna (pakai colorscheme), menentukan halaman awal lewat properti home, mengatur navigasi antar halaman (routes, navigator), serta menyediakan material design berupa tombol,Appbar,snackbar,dll. Dengan fungsi yang banyak ini membuat Materiall menjadi root karena tanpa dia maka widget seperti Scaffold, AppBar, ElevatedButton, atau SnackBar tidak bisa digunakan, sebab semuanya membutuhkan konteks Material Design yang disediakan oleh MaterialApp.

4. Jelaskan perbedaan antara StatelessWidget dan StatefulWidget. Kapan kamu memilih salah satunya? 
statelesswidget itu biasanya tidak punya state (data yang bisa dirubah) sehingga jika sekali dibangun maka tampilannya tidak akan berubah kecuali direbuild semuanya. StatefullWidget itu mempunyai state internal yang bisa berubah (input,animasi,dll) serta bisa memanggil setState() untuk memperbarui tampilan. 

StatelessWidget biasa dipakai untuk tampilan statis seperti teks,tombol, logo dan header. Sedangkan untuk statefulwidget digunakan kalau kita membutuhkan perubahan dinamis , misal form,animasi atau data dari API. Dalam tugas ini saya menggunakan stateless widget karena tombool saya tidak berubah tampilan saat ditekan. 

5. Apa itu BuildContext dan mengapa penting di Flutter? Bagaimana penggunaannya di metode build? 

BuildContext adalah objek yang menyimpan informasi mengenai posisi suatu widget di dalam widget tree.Setiap build() dijalankan, flutter akan memberikan BuildContext untuk memberitahu bahwa dimana posisi widget itu berada, siapa parentnya serta apa saja yang diwarisi dari atas.

biasa seperti:
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('PAT SHOP'),
    ),
  );
}

context disini sangat berperan penting untuk mengakses theme.off (context) (warna tema), akses navigator.of (context) (pindah halaman), akses scaffoldmessenger.of(context) (snackbar). Tanpa context, maka flutter tidak tahu widget ini sedang dimana di treenya

Contoh penggunaan BuildContext: 

onPressed: () {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text("Kamu telah menekan tombol ${item.name}"),
      ),
    );
}

ScaffoldMessenger.of(context) nantinya flutter akan mencari widget Scaffold terdekat di atas tombol. Karena tombol itu ada di dalam Scaffold, maka flutter tahu di mana harus menampilkan SnackBar-nya. Jadi tanpa BuildContext, Flutter tidak akan tahu Snackbar itu harus muncul di layar mana.

6. Jelaskan konsep "hot reload" di Flutter dan bagaimana bedanya dengan "hot restart".

Hot reload konsepnya adalah menyuntikkan perubahan kode ke aplikasi tanpa harus kehilangan state (misal data di layar tidak di reset), Hot restart konsepnya adalah merestart aplikasi dari awal dan membangun ulang widget tree. Selain itu, semua state akan hilang . 

Efek dari hot reload akan sangat cepat dan cocok untuk ubah UI atau logika kecil, sedangkan untuk hot restart akan lebih lambar tapi bersih karena cocok untuk ubah kode besar seperti main atau insialisasi global.
