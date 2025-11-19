Tugas 9 

1. Jelaskan mengapa kita perlu membuat model Dart saat mengambil/mengirim data JSON? Apa konsekuensinya jika langsung memetakan Map<String, dynamic> tanpa model (terkait validasi tipe, null-safety, maintainability)?

model memberikan type safety, validasi sederhana dan maintainability, sedagkan jika langsung menggunakan Map <String,dynamic> raw berisiko runtime error dan sulit dikelola. Manfaat model: 
-Tipe yang jelas & null-safety
ProductEntry.price bertipe int → compiler membantu mencegah salah pemakaian.
Dengan Map harus selalu melakukan cast json['price'] as int atau int.parse(...)—raw cast bisa throw di runtime.

-Deserialisasi/Serialisasi terpusat
fromJson() / toJson() memusatkan aturan (nama field, format tanggal, default value).

-Validasi & normalisasi
Bisa atur price = json['price'] ?? 0, thumbnail = json['thumbnail'] ?? '', atau men-convert tipe. Dengan Map logic ini tidak bisa rapi di banyak tempat.

-Refactor & maintainability
Kalau field backend berubah maka hanya ubah model Dart, bukan seluruh kode.

-Dokumentasi implisit
Model menjelaskan kontrak data (apa saja field, tipe, opsional/required).

Konsekuensi kalau pakai Map<String,dynamic> langsung:

-Banyak as/tryParse di tiap tempat maka kode berantakan.
-Risiko NoSuchMethodError/TypeError saat data tak sesuai.
-Sulit mengaplikasikan null-safety dengan konsisten.
-Sulit menulis unit tests (perilaku tersebar).


2. Apa fungsi package http dan CookieRequest dalam tugas ini? Jelaskan perbedaan peran http vs CookieRequest.

http (package:http):
-Library HTTP low-level untuk melakukan GET/POST/PUT/DELETE.
-Tidak otomatis menyimpan/carry cookie antar request (kecuali kamu kelola sendiri).
-Cocok untuk request stateless (public API, token-in-header, dll).

CookieRequest (dari pbp_django_auth):
-Wrapper yang mengurus: cookie jar, CSRF token, session cookie, dan helper postJson, get, logout, dsb.
-Dirancang untuk integrasi dengan backend Django yang pakai session-based authentication (session cookie + CSRF).
-Menyederhanakan autentikasi: login meng-set cookie, CookieRequest menyimpan cookie dan mengikutsertakan cookie pada request berikutnya otomatis.
-Mempermudah pemanggilan API yang butuh CSRF (meng-handle token CSRF).

Perbedaan dari keduanya:

-http = alat HTTP generik (menangani cookie/CSRF manual).
-CookieRequest = client yang sudah siap untuk Django/session (sangat praktis untuk autentikasi berbasis cookie).

3. Jelaskan mengapa instance CookieRequest perlu untuk dibagikan ke semua komponen di aplikasi Flutter.
Instance cookieRequest perlu untuk dibagikan ke semua komponen di aplikasi flutter karena: 

-Satu source-of-truth untuk cookie/session — semua widget butuh mengakses credential (cookie) agar request berikutnya autentik. Jika tiap widget buat instance sendiri, cookie tidak konsisten.
-Mudah di-inject ke widget: Provider/context.watch<CookieRequest>() menjadikan akses mudah di mana saja (forms, list, drawer, dsb).
-Reactive UI: saat login/logout terjadi, provider dapat notify listeners (mis. mengubah state login) sehingga UI (menu, drawer) bisa update otomatis.
-Tidak perlu passing parameter: menghindari meneruskan request di constructor widget berkali-kali.
-Lifecycle & persistence: instance terinstansiasi sekali (persist cookie jar) sampai app di-kill.

4. Jelaskan konfigurasi konektivitas yang diperlukan agar Flutter dapat berkomunikasi dengan Django. Mengapa kita perlu menambahkan 10.0.2.2 pada ALLOWED_HOSTS, mengaktifkan CORS dan pengaturan SameSite/cookie, dan menambahkan izin akses internet di Android? Apa yang akan terjadi jika konfigurasi tersebut tidak dilakukan dengan benar?

- 10.0.2.2 (Android emulator)

Android emulator (default AVD) memetakan host machine localhost ke 10.0.2.2.
digunakan saat Flutter (Android emulator) ingin mengakses Django yang berjalan di mesin development (localhost).Jika tidak maka request ke 127.0.0.1 dari emulator akan mengarah ke emulator sendiri, bukan host akan gagal koneksi.

- ALLOWED_HOSTS di Django

Django akan memblokir Host header yang tidak tercantum di ALLOWED_HOSTS untuk mencegah host-header attacks. Harus menambahkan si localhost, 127.0.0.1, 10.0.2.2, dan (opsional) IP perangkat testing. Jika tidak maka request akan ditolak dengan 400 Bad Request.

- CORS (Cross-Origin Resource Sharing), sangat penting untuk Flutter Web & kadang mobile karena browser menegakkan SOP. Kalau Flutter (web) di http://localhost:63342 memanggil backend http://localhost:8000, browser memeriksa CORS.

Solusi dengan memakai django-cors-headers dan set CORS_ALLOWED_ORIGINS atau CORS_ALLOW_ALL_ORIGINS=True (dev).

Jika tidak: browser menolak request (CORS error), devtools shows blocked by CORS.

-SameSite & cookie settings (SESSION_COOKIE_SAMESITE, CSRF_COOKIE_SAMESITE, Secure)

lebih modern browser menolak cookie saat cross-site request kecuali cookie SameSite=None; Secure. Untuk mobile & web (cross-origin) wajib menggunakan:

SESSION_COOKIE_SAMESITE = 'None'

CSRF_COOKIE_SAMESITE = 'None'

SESSION_COOKIE_SECURE = True jika menggunakan HTTPS (for production)

Jika tidak maka cookie session tidak tersimpan/terkirim ke server sehingga user tidak dianggap login.

- Android: izin akses internet (AndroidManifest.xml)

Tambahkan <uses-permission android:name="android.permission.INTERNET"/>.
Jika tidak maka app Android tidak bisa melakukan HTTP request sama sekali (NetworkOnMainThread? atau connection refused).

-SSL / HTTPS di production

Cookie Secure harus dipakai untuk SameSite=None; jika testing di http tanpa https, cookie mungkin ditolak di beberapa browser. Untuk dev bisa gunakan SESSION_COOKIE_SECURE=False tetapi hati-hati (production wajib pakai https).

Konsekuensi kalau salah konfigurasi: 
Koneksi gagal, 400/403/401, CORS blocked, cookie tidak tersimpan maka fitur login/session tidak jalan sehingga API yang membutuhkan autentikasi mengembalikan redirect/HTML (bukan JSON) sehingga parsing error di Flutter maka akan  spinner, crash, atau silent failure.

5. Jelaskan mekanisme pengiriman data mulai dari input hingga dapat ditampilkan pada Flutter.

-User input: user isi form pada Flutter (TextFormField → data di state _title, _price, _stock).
-Validasi di client: validator pada Form memeriksa format & required.
-Serialize: data dikemas jadi JSON (jsonEncode({...})) atau Map untuk postJson.
-Mengirim ke backend: gunakan request.postJson(url, jsonEncode({...})) atau http.post(url, body: json).
-CookieRequest akan menambahkan header CSRF + cookie jika perlu.
-Django menerima: view menerima request body (request.body, json.loads) atau request.POST jika form-data.
-Server-side validation: model form atau manual validation (cek tipe, panjang, category valid).
-Simpan ke DB: Model.save() dan di commit.
-Response: Django kirim JSON sukses (mis. {"status":"success","id":"..."}) atau error response.
-Flutter menerima response:
  jika success → update UI (refetch list atau insert ke local list) dan navigasi / toast.
  jika error → tampilkan error message.

-Tampilan list: Flutter memanggil API list (request.get('/json/')) → parse JSON → ProductEntry.fromJson → setState/ FutureBuilder menampilkan ListView.

6.Jelaskan mekanisme autentikasi dari login, register, hingga logout. Mulai dari input data akun pada Flutter ke Django hingga selesainya proses autentikasi oleh Django dan tampilnya menu pada Flutter.

A. Register

Flutter send POST ke endpoint register (/register/) dengan username/password.
Django UserCreationForm memvalidasi & menyimpan user.
Response: sukses atau error (JSON).
Flutter menampilkan pesan dan navigasi ke login.

b. Login

Flutter mengirim POST ke /login/ (pakai CookieRequest.postJson) dengan credentials.Django memvalidasi: authenticate() + login().Jika autentikasi sukses, Django membuat session dan mengembalikan Set-Cookie: sessionid=... di response header.Jika request adalah AJAX dan kamu gunakan CookieRequest, cookie akan tersimpan di CookieRequest instance. Untuk POST yang mengubah state, Django/Browser juga memerlukan CSRF token — CookieRequest mengambil CSRF dan menambahkan header X-CSRFToken.

Flutter menyimpan state login (via provider) atau mengandalkan CookieRequest's cookie jar.
UI: setelah login sukses, aplikasi menampilkan menu yang hanya untuk user login (mis. My Products, Create Product).

C. Akses API yang membutuhkan autentikasi

Cookie session dikirim setiap request otomatis oleh CookieRequest. Django memeriksa session untuk mengetahui request.user.

D. Logout

Flutter panggil endpoint logout (mis. /auth/logout/) via request.logout() atau post.Django menghapus session server-side (logout(request)), dan mengembalikan response serta cookie expired.CookieRequest menghapus cookie lokal.Flutter menerima sukses dan mengubah UI (redirect ke LoginPage, sembunyikan menu yang butuh autentikasi).

Catatan CSRF:

Untuk session-based auth, Django memerlukan token CSRF untuk POST/PUT/DELETE.
CookieRequest membantu ambil & kirim token ini.Alternatif: gunakan token-based (JWT) sehingga CSRF tidak diperlukan, tapi memerlukan header Authorization.

7. Jelaskan bagaimana cara kamu mengimplementasikan checklist di atas secara step-by-step! (bukan hanya sekadar mengikuti tutorial).

Dalam project ini, saya mengimplementasikan semua checklist PBP secara bertahap dan terstruktur, tidak asal mengikuti tutorial. Pertama, saya mulai dari sisi backend Django, memastikan model, view, serta endpoint JSON berfungsi. Saya membuat model Toko lengkap dengan field name, price, description, thumbnail, category, stock, is_featured, dan relasi user. Dari model ini, saya membuat beberapa endpoint JSON, terutama /json/ untuk mengambil semua produk, dan /json/user/ untuk produk yang hanya dimiliki user yang sedang login. Endpoint ini penting karena kelak dipakai oleh halaman All Products dan My Products di Flutter. Selain itu, saya membuat endpoint create-flutter/ untuk menerima POST JSON dari Flutter ketika user menambah produk baru. Semua endpoint saya cek dulu dengan Postman supaya yakin formatnya benar.

Selanjutnya, saya juga menyesuaikan konfigurasi Django seperti menambahkan 10.0.2.2 pada ALLOWED_HOSTS, menyalakan CORS, dan mengatur cookie agar Flutter (terutama Android emulator) bisa mengakses Django tanpa diblokir. Tahap backend saya pastikan sudah benar sebelum masuk ke Flutter supaya tidak ada error seperti looping spinner.

Masuk ke Flutter, saya mulai dengan membuat model Dart ProductEntry karena model ini yang akan memetakan JSON menjadi objek Dart. Dengan model ini, saya bisa menjaga data tetap stabil, lebih aman secara tipe, dan gampang di-maintain. Setelah itu saya membuat halaman ProductEntryListPage untuk menampilkan semua produk dari /json/. Halaman ini saya bangun menggunakan FutureBuilder, sehingga saat Future proses fetch JSON belum selesai, UI menampilkan spinner; setelah selesai, datanya berubah menjadi list kartu produk.

Untuk fitur My Products, saya membuat halaman baru MyProductEntryListPage. Di halaman ini saya memanggil endpoint /json/user/ agar produk yang muncul hanya produk milik user yang login. Setelah data diterima, saya tetap memanfaatkan widget ProductEntryCard yang sama seperti All Products. Saya juga menambahkan navigasi ke ProductDetailPage ketika kartu ditekan, sehingga perilaku My Product dan All Product tetap konsisten.

Pada bagian Create Product, saya memodifikasi form Flutter supaya ketika user menekan tombol Simpan, Flutter mengirim request POST JSON ke Django melalui fungsi postJson. Data seperti name, description, price, stock, sampai is_featured ikut dikirim. Jika Django membalas dengan status success, Flutter menampilkan snackbar keberhasilan, lalu kembali ke halaman utama.

Selanjutnya saya mengimplementasikan fitur Logout. Pada kartu menu di Flutter (Product Card), saya menambahkan kondisi else if (item.name == "Logout") yang memanggil request.logout() milik CookieRequest. Fungsi ini otomatis menghapus session cookie sehingga Django menganggap user sudah logout. Setelah logout berhasil, Flutter berpindah ke halaman login dan menampilkan snackbar selamat tinggal seperti yang ada di template tugas.

Pada bagian menu, saya juga menambahkan tombol My Products, All Products, dan Logout sehingga ketiganya menjadi bagian yang bisa diakses user dari UI. Tombol All Products mengarah ke halaman list seluruh item, tombol My Products mengarah pada list produk milik user, dan tombol Logout menjalankan logika logout yang sudah saya siapkan.

Dengan begitu, seluruh fitur mulai dari pengelolaan data, autentikasi, pembuatan produk baru, serta filtering berdasarkan user, semuanya saya implementasikan bukan sekadar menyalin tutorial, tetapi saya pahami logikanya, saya sesuaikan dengan proker yang saya buat di Flutter dan Django, dan saya perbaiki ketika muncul error seperti infinite loading dan kesalahan mapping JSON.


-----------------------------------------------------------------------------------------------------------------------------------------------------------
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