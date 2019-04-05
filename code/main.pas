program main;
{Program Utama Perpustakaan}
uses
	uload,
	usave,
	ubook,
	uuser,
	udate,
	umissing_history,
	uborrow_history,
	ureturn_history;

{KAMUS GLOBAL}
var
	books		: tbook;
	users		: tuser;
	borrows 	: tborrow;
	returns 	: treturn;
	missings	: tmissing;

	ptrbooks	: pbook;
	ptruser		: puser;
	ptrborrow	: pborrow;
	ptrreturn	: preturn;
	ptrmissing	: pmissing;

	activeUser	: User;
	query		: string;
	i : integer;


{FUNGSI DAN PROSEDUR}
procedure printFeatures();
	{DESKRIPSI	: (F00) menampilkan fitur-fitur pada layar}
	{PARAMETER	: - }
	{RETURN 	: - }

	{ALGORITMA}
	begin
		writeln('Selamat datang di Perpustakaan Tengah Gurun');
		writeln('$ register				: Regitrasi Akun');
		writeln('$ login 				: Login');
		writeln('$ cari 				: Pencarian Buku berdasar Kategori');
		writeln('$ caritahunterbit 		: Pencarian Buku berdasar Tahun Terbit');
		writeln('$ pinjam_buku 			: Pemimjaman Buku');
		writeln('$ kembalikan_buku 		: Pengembalian Buku');
		writeln('$ lapor_hilang			: Melaporkan Buku Hilang');
		writeln('$ lihat_laporan 		: Melihat Laporan Buku yang Hilang');
		writeln('$ tambah_buku 			: Menambahkan Buku Baru ke Sistem');
		writeln('$ tambah_jumlah_buku 	: Melakukan Penambahan Jumlah Buku ke Sistem');
		writeln('$ riwayat 				: Melihat Riwayat Peminjaman');
		writeln('$ statistik 			: Melihat Statistik');
		writeln('$ load 				: Load File');
		writeln('$ save 				: Save File');
		writeln('$ cari_anggota 		: Pencarian Anggota');
		writeln('$ exit					: Exit');
		write('$ ');
	end;

procedure loadAllFiles();
	{DESKRIPSI	: (F13) meminta input nama file dari user kemudian membaca
	isi file tsb dan memuatnya pada array yang bersangkutan}
	{PARAMETER	: - }
	{RETURN 	: - }

	{KAMUS LOKAL}
	var		
		filename	: string;

	{ALGORITMA}
	begin
		ptrbooks^ 	:= books;
		ptruser^	:= users;
		ptrborrow^ 	:= borrows;
		ptrreturn^	:= returns;
		ptrmissing^	:= missings;

		write('Masukkan nama File Buku: '); readln(filename);
		loadbook(filename, ptrbooks);
		books 		:= ptrbooks^;
		
		write('Masukkan nama File User: '); readln(filename);
		loaduser(filename, ptruser);
		users 		:= ptruser^;
		
		write('Masukkan nama File Peminjaman: '); readln(filename);
		loadborrow(filename, ptrborrow);
		borrows 	:= ptrborrow^;

		write('Masukkan nama File Pengembalian: '); readln(filename);
		loadreturn(filename, ptrreturn);
		returns 	:= ptrreturn^;

		write('Masukkan nama File Buku Hilang: '); readln(filename);
		loadmissing(filename, ptrmissing);
		missings	:= ptrmissing^;

		writeln();
		writeln('File perpustakaan berhasil dimuat!');
		writeln();
	end;

procedure saveAllFiles();
	{DESKRIPSI	: (F14) meminta input nama file dari user kemudian mengisi
	file tsb dengan array yang bersangkutan}
	{PARAMETER	: - }
	{RETURN 	: - }

	{KAMUS LOKAL}
	var
		filename	: string;

	{ALGORITMA}
	begin
		ptrbooks^ 	:= books;
		ptruser^	:= users;
		ptrborrow^ 	:= borrows;
		ptrreturn^	:= returns;
		ptrmissing^	:= missings;


		write('Masukkan nama File Buku: '); readln(filename);
		savebook(filename, ptrbooks);
		
		write('Masukkan nama File User: '); readln(filename);
		saveuser(filename, ptruser);
		
		write('Masukkan nama File Peminjaman: '); readln(filename);
		saveborrow(filename, ptrborrow);

		write('Masukkan nama File Pengembalian: '); readln(filename);
		savereturn(filename, ptrreturn);

		write('Masukkan nama File Buku Hilang: '); readln(filename);
		savemissing(filename, ptrmissing);

		writeln();
		writeln('Data berhasil disimpan!');
		writeln();
	end;


procedure init();
	{DESKRIPSI	: prosedur dijalankan sekali, yaitu pada awal program berjalan}
	{PARAMETER	: - }
	{RETURN 	: - }

	{ALGORITMA}
	begin
		query := 'load';
		writeln('$ load');

		activeUser.username := 'Anonymous';
		activeUser.password	:= '12345678';
		activeUser.fullname	:= 'Anonymous';
		activeUser.address	:= '';
		activeUser.isAdmin	:= false;

		new(ptrbooks);
		new(ptruser);
		new(ptrborrow);
		new(ptrreturn);
		new(ptrmissing);
	end;

procedure exitProgram();
	{DESKRIPSI	: (F16) prosedur dijalankan sekali, yaitu saat menerima query exit}
	{PARAMETER	: - }
	{RETURN 	: - }

	{KAMUS LOKAL}
	var
		wantSave: char;

	{ALGORITMA}
	begin
		{Validasi Input}
		repeat
			writeln('Simpan data? (Y/N)');
			write('$ '); readln(wantSave);
		until (wantSave = 'Y') or (wantSave = 'y') or (wantSave = 'N') or (wantSave = 'n');

		{Save file sebelum program ditutup}
		if (wantSave = 'Y') or (wantSave = 'y') then begin
			saveAllFiles();
		end;
		write('Press ANY key to close program'); readln();
		exit();
	end;


{ALGORITMA}
begin
	init();
	while not (query = 'exit') do begin
		case query of
	{		// 'register'				: register();}
	{		// 'login' 				: login();}
	{		// 'cari' 					: cari();}
	{		// 'caritahunterbit' 		: caritahunterbit();}
	{		// 'pinjam_buku' 			: pinjam_buku();}
	{		// 'kembalikan_buku' 		: kembalikan_buku();}
	{		// 'lapor_hilang'			: lapor_hilang();}
	{		// 'lihat_laporan' 		: lihat_laporan();}
	{		// 'tambah_buku' 			: tambah_buku();}
	{		// 'tambah_jumlah_buku' 	: tambah_jumlah_buku();}
	{		// 'riwayat' 				: riwayat();}
	{		// 'statistik' 			: statistik();}
			'load' 					: loadAllFiles();
			'save' 					: saveAllFiles();
	{		// 'cari_anggota' 			: cari_anggota();}
		end;
		printFeatures(); readln(query);
	end;

	{DEBUG}
	writeln('======== DEBUG ========');
	writeln('BOOKS');
	for i:= 1 to bookNeff do writeln(books[i].id, ' ', books[i].title);
	writeln();

	writeln('USERS');
	for i:= 1 to userNeff do writeln(users[i].username, ' ', users[i].password);
	writeln();
	
	writeln('BORROWS');
	for i:= 1 to borrowNeff do writeln(borrows[i].username, ' ', borrows[i].borrowDate.year);
	writeln();

	writeln('RETURNS');
	for i:= 1 to returnNeff do writeln(returns[i].id, ' ', returns[i].returnDate.day);
	writeln();

	writeln('MISSINGS');
	for i:= 1 to missingNeff do writeln(missings[i].id, ' ', missings[i].username);
	writeln('======================');

	{EXIT}
	exitProgram();
end.
