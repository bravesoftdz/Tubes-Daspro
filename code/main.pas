program main;
{Program Utama Sistem Manajemen Perpustakaan}
{Dibuat oleh KELOMPOK 3 KELAS 03 DASPRO IF1210 STEI ITB 2018}
{REFERENSI : https://tpb.kuliah.itb.ac.id/pluginfile.php/104511/mod_resource/content/1/IF1210_12_Skema_Standar_Bag2_040419.pdf (SkemaStandar Pemrosesan Array)
			 https://tpb.kuliah.itb.ac.id/pluginfile.php/10273/mod_resource/content/1/ContohPrgKecilPascal_Agt08.pdf (Contoh Program Kecil Bahasa Pascal)
			 https://www.tutorialspoint.com/pascal/pascal_pointers.htm
			 https://stackoverflow.com/questions/6320003/how-do-i-check-whether-a-string-exists-in-an-array
			 http://www.asciitable.com/}

{DAFTAR UNIT}
{F01, F02, F15 				- uuserutils}
{F03, F04 				- ubooksearch}
{F05, F06, F07, F09, F10 		- ubookio}
{F08, F11, F12 				- ubookoutput}
{F13 					- uload}
{F14 					- usave}
{Definisi ADT 				- ubook, uuser, udate}
{hashing (MD5)				- k03_kel3_md5}
{fungsi pembantu			- k03_kel3_utils}
uses
	uload, usave, udate,
	ubook, ubooksearch, ubookio, ubookoutput,
	uuser, uuserutils,
	ucsvwrapper,
	k03_kel3_utils, k03_kel3_md5;

{KAMUS GLOBAL}
var
	books			: tbook;
	users			: tuser;
	borrows 		: tborrow;
	returns 		: treturn;
	missings		: tmissing;
	
	ptrbook 		: pbook;
	ptruser			: puser;
	ptrborrow		: pborrow;
	ptrreturn		: preturn;
	ptrmissing		: pmissing;
	
	activeUser		: User;
	ptractiveUser 		: psingleuser;

	query			: string;
	firstLoad		: boolean;
	notAdminMsg		: string;
	notLoggedInMsg		: string;
	loggedInMsg	 	: string;

{FUNGSI DAN PROSEDUR}
procedure init();
	{DESKRIPSI	: prosedur dijalankan sekali, yaitu pada awal program berjalan}
	{I.S. 		: Sembarang}
	{F.S.		: query terdefinisi, activeUser terdefinisi, pointer terdefinisi}
	{Proses 	: menginisiasi variabel-variabel yang akan digunakan pada program utama}

	{ALGORITMA}
	begin
		query := 'load';
		writeln('$ load');
		firstLoad := true;

		{INISIASI POINTER array of ADT}
		new(ptrbook);
		new(ptruser);
		new(ptrborrow);
		new(ptrreturn);
		new(ptrmissing);
		new(ptractiveUser);

		ptractiveUser^ 	:= activeUser;
		setToDefaultUser(ptractiveUser);
		activeUser 		:= ptractiveUser^;
		notAdminMsg 	:= 'Akses ditolak. Anda bukan admin!';
		notLoggedInMsg 	:= 'Anda belum login. Silakan login terlebih dahulu';
		loggedInMsg 	:= 'Anda masih logged in. Silakan logout terlebih dahulu.'
	end;

procedure registerUser();
	{DESKRIPSI	: (F01) melakukan registrasi akun dari user dan admin}
	{I.S. 		: array of User terdefinisi}
	{F.S.		: keberhasilan registrasi ditampilkan di layar}
	{Proses 	: Menanyakan nama lengkap, alamat, username dan password user, dan layar menampilkan keberhasilan registrasi}

	{KAMUS LOKAL}
	var
		newUser 	: user;
		pnewUser 	: psingleuser;

	{ALGORITMA}
	begin
		if (activeUser.isAdmin) then begin
			new(pnewUser);
			write('Masukkan nama pengunjung: '    ); readln(newUser.fullname);
			write('Masukkan alamat pengunjung: '  ); readln(newUser.address);
			write('Masukkan username pengunjung: '); readln(newUser.username);

			newUser.fullname := wraptext(newUser.fullname);
			newUser.address  := wraptext(newUser.address);
			newUser.username := wraptext(newUser.username);
			pnewUser^ 	 := newUser;

			write('Masukkan password pengunjung: ');
			newUser.password := hashMD5(readpass(pnewUser));
			newUser.isAdmin  := false;

			pnewUser^ := newUser;
			registerUserUtil(pnewUser, ptruser);
		end else begin
			writeln(notAdminMsg);
		end;	
	end;

procedure login();
	{DESKRIPSI	: (F02) melakukan login dari akun user yang telah dibuat}
	{I.S. 		: array of User terdefinisi}
	{F.S.		: berhasil atau gagalnya login}
	{Proses 	: User menginput username dan password, layar akan menampilkan keberhasilan login jika username dan password cocok
				  dengan yang sudah terdaftar}

	{ALGORITMA}	
	begin
		if (activeUser.username = wraptext('Anonymous')) then begin
			write('Masukkan username: '); readln(activeUser.username);
			activeUser.username := wraptext(activeUser.username);

			ptractiveUser^ := activeUser;
			write('Masukkan password: ');			
			activeUser.password := hashMD5(readpass(ptractiveUser));

			ptractiveUser^ := activeUser;
			loginUtil(ptractiveUser, ptruser);
			activeUser := ptractiveUser^;
		end else begin
			writeln(loggedInMsg);
		end;
	end;

procedure findBookByCategory();
	{DESKRIPSI	: (F03) mecari buku dengan kategori tertentu sesuai input dari user}
	{I.S. 		: array of Book terdefinisi}
	{F.S.		: ID buku, judul buku, penulis buku dengan kategori yang diinput ditampilkan di layar dengan judul tersusun sesuai abjad}
	{Proses 	: Menanyakan pada user kategori apa yang dicari, lalu mencari ID, judul dan penulis buku tersebut
				  lalu menampilkannya di layar}

	{KAMUS LOKAL}
	var
		category: string;

	{ALGORITMA}
	begin
		writeln('Kategori Tersedia:');
		writeln('sastra');
		writeln('sains');
		writeln('manga');
		writeln('sejarah');
		writeln('programming');
		writeln();
		write('Masukkan kategori: '); readln(category);
		findBookByCategoryUtil(category, ptrbook);
		while (categoryValid(category)=False) do begin
			write('Masukkan kategori: '); readln(category);
			findBookByCategoryUtil(category, ptrbook);
		end;
	end;

procedure findBookByYear();
	{DESKRIPSI	: (F04) mencari buku berdasarkan tahun yang diinput dari user.}
	{I.S. 		: array of Book terdefinisi.}
	{F.S.		: ID buku, judul buku, penulis buku dengan kategori yang diinput ditampilkan di layar dengan judul
			  tersusun sesuai abjad.}
	{Proses 	: Menanyakan pada user buku terbitan tahun berapa yang dicari, lalu mencari ID, judul dan penulis
			  buku tersebut lalu menampilkannya di layar.}

	{KAMUS LOKAL}
	var
		year 		: integer;
		category 	: string;
	
	{ALGORITMA}
	begin
		write('Masukkan tahun: '   ); readln(year);
		write('Masukkan kategori: '); readln(category);
		findBookByYearUtil(year, category, ptrbook);
	end;

procedure borrowBook();
	{DESKRIPSI	: (F05) Menerima data buku yang dipinjam dengan menerima data id buku, judul buku, dan tanggal peminjaman.}
	{I.S. 		: array of book terdefinisi, pointer pada book.csv terdefinisi.}
	{F.S.		: data buku dipinjam tersimpan.}
	{Proses 	: mengurangi jumlah buku dipinjam dalam data jika stok tersedia.}

	{KAMUS LOKAL}
	var
		newBorrow	: BorrowHistory;
		pnewBorrow	: psingleborrow;
		tmp 		: string;

	{ALGORITMA}
	begin
		if (activeUser.username <> wraptext('Anonymous')) then begin
			write('Masukkan id buku yang ingin dipinjam: '); readln(newBorrow.id);
			write('Masukkan tanggal hari ini (DD/MM/YYYY): '); readln(tmp);

			newBorrow.username   := activeUser.username;
			newBorrow.isBorrowed := true;
			newBorrow.borrowDate := StrToDate(tmp);
			newBorrow.returnDate := DaysToDate(DateToDays(newBorrow.borrowDate) + 7);

			new(pnewBorrow);
			pnewBorrow^ := newBorrow;
			borrowBookUtil(pnewBorrow, ptrborrow, ptrbook);
		end else begin
			writeln(notLoggedInMsg);
		end;
	end;

procedure returnBook();
	{DESKRIPSI	: (F06) Menerima data buku yang dikembalikan dengan menerima id buku, judul buku, dan tanggal pengembalian.}
	{I.S. 		: bookid bertipe integer, username bertipe string, dan pointer terdefinisi.}
	{F.S.		: data buku yang dikembalikan tersimpan.}
	{Proses 	: menambahkan jumlah buku yang dikembalikan dalam data csv.}

	{KAMUS LOKAL}
	var
		id: integer;

	{ALGORITMA}
	begin
		if (activeUser.username <> wraptext('Anonymous')) then begin
			write('Masukkan id buku yang ingin dikembalikan: '); readln(id);
			returnBookUtil(id, activeUser.username, ptrreturn, ptrborrow, ptrbook);
		end else begin
			writeln(notLoggedInMsg);
		end;
	end;


procedure addMissingBook();
	{DESKRIPSI  : (F07) Menerima laporan buku hilang dengan menerima data id buku, judul buku, dan tanggal pelaporan}
	{I.S        : array of book terdefinisi, pointer terdefinisi (pointer pada book.csv)}
	{F.S        : data buku hilang tersimpan }
   	{Proses     : menambahkan data buku yang hilang ke ptrarray, beserta mengurangi jumlah buku yang ada di ptrbook.}
   	
	{KAMUS LOKAL}
	var
		tmp 			: string;
		newMissingBook 	: MissingBook;
		ptrnewmissing 	: psinglemissing;

	{ALGORITMA}
	begin
		if (activeUser.username <> wraptext('Anonymous')) then begin
			write('Masukkan id buku: '			); readln(newMissingBook.id);
			write('Masukkan judul buku: '		); readln();
			write('Masukkan tanggal pelaporan: '); readln(tmp);
			newMissingBook.reportDate 	:= StrToDate(tmp);
			newMissingBook.username 	:= activeUser.username;

			new(ptrnewmissing);
			ptrnewmissing^ := newMissingBook;
			addMissingBookUtil(ptrnewmissing, ptrmissing, ptrbook);
		end else begin
			writeln(notLoggedInMsg);
		end;
    end;

procedure showMissings();
   	{DESKRIPSI  : (F08) Menampilkan data-data buku yang hilang}
   	{I.S        : pointer menunjuk ke missing terdefinisi (pointer pada book.csv)}
 	{F.S        : data buku hilang ditampilkan }
  	{Proses     : menampilkan data-data buku hilang berdasarkan id dan tanggal dari ptrmissing, dan judul dari ptrbook}

	{ALGORITMA}
	begin
		if (activeUser.isAdmin) then begin
			showMissingsUtil(ptrmissing, ptrbook);
		end else begin
			writeln(notAdminMsg);
		end;
	end;

procedure addNewBook();
	{DESKRIPSI  : (F09) Menerima data buku baru dan memasukkannya ke book.csv,dengan menerima masukkan id buku, judul
                      pengarang,jumlah,tahun terbit,dan kategori}
        {I.S        : pointer buku dan array terdefinisi (pointer pada book.csv)}
   	{F.S        : data buku baru tersimpan }
        {Proses     : menambahkan data buku baru ke ptrarray}

	{KAMUS LOKAL}
	var
		newBook 	: Book;
		pnewBook 	: psinglebook;

	{ALGORITMA}
	begin
		if (activeUser.isAdmin) then begin
	        writeln('Masukkan informasi buku yang ditambahkan:');
	        write('Masukkan id buku: '			); readln(newBook.id);
			write('Masukkan judul buku: '		); readln(newBook.title);
	        write('Masukkan pengarang buku: '	); readln(newBook.author);
	        write('Masukkan jumlah buku: '		); readln(newBook.qty);
	        write('Masukkan tahun terbit buku: '); readln(newBook.year);
	        write('Masukkan kategori buku: '	); readln(newBook.category);

			newBook.title := wraptext(newBook.title);	        
			newBook.author := wraptext(newBook.author);

	        new(pnewBook);
	        pnewBook^ := newBook;
			addNewBookUtil(pnewBook, ptrbook);
		end else begin
			writeln(notAdminMsg);
		end;
	end;

procedure addBookQty();
	{DESKRIPSI	: (F10) Melakukan penambahan jumlah buku ke sistem}
	{I.S. 		: Sembarang}
	{F.S.		: jumlah buku dengan id ID bertambah sebanyak qty}
	{Proses 	: Meminta input id buku dan jumlah yang ingin ditambahkan,
			  lalu menambahkan jumlah buku ber id ID}

	{KAMUS LOKAL}
	var
		ID, qty : integer;

	{ALGORITMA}
	begin
		if (activeUser.isAdmin) then begin
			write('Masukkan ID Buku: '); readln(ID);
			write('Masukkan jumlah buku yang ditambahkan: '); readln(qty);
			addBookQtyUtil(ID, qty, ptrbook);
		end else begin
			writeln(notAdminMsg);
		end;
	end;

procedure showBorrowHistory();
	{DESKRIPSI	: (F11) Menampilkan riwayat peminjaman}
	{I.S. 		: Suatu username yang sedang aktif saat itu}
	{F.S.		: Riwayat peminjaman dari username ditampilkan seluruhnya}
	{Proses 	: Menggunakan skema pengulangan untuk menampilkan riwayat username}

	{KAMUS LOKAL}
	var
		username : string;

	{ALGORITMA}
	begin
		if (activeUser.isAdmin) then begin
			write('Masukkan username pengunjung: '); readln(username);
			writeln('Riwayat:');
			showBorrowHistoryUtil(wraptext(username), ptrbook, ptrborrow);
		end else begin
			writeln(notAdminMsg);
		end;
	end;

procedure showStats();
   	{DESKRIPSI  : (F12) Menampilkan data statistik berupa admin, pengunjung, dan 5 jenis buku berdasarkan user.csv dan book.csv}
   	{I.S        : ptrbook valid (pointer pada book.csv), dan ptruser valid (pointer pada user.csv)}
   	{F.S        : Menampilkan jenis-jenis statistik di layar }
        {Proses     : Menulis jenis-jenis statistik ke layar berdasarkan book.csv}

	{ALGORITMA}
	begin
		if (activeUser.isAdmin) then begin
			showStatsUtil(ptrbook, ptruser);
		end else begin
			writeln(notAdminMsg);
		end;
	end;


procedure loadAllFiles();
	{DESKRIPSI	: (F13) meminta input nama file dari user kemudian membaca
				  isi file tsb dan memuatnya pada array yang bersangkutan}
	{I.S. 		: Sembarang}
	{F.S.		: Semua array of ADT terisi sesuai input nama file}
	{Proses 	: Meminta input nama file dari user, lalu mengisi array of ADT}

	{KAMUS LOKAL}
	var
		filename	: string;

	{ALGORITMA}
	begin
		if ((activeUser.isAdmin) or firstLoad) then begin
			firstLoad 	:= false;
			ptrbook^ 	:= books;
			ptruser^	:= users;
			ptrborrow^ 	:= borrows;
			ptrreturn^	:= returns;
			ptrmissing^	:= missings;

			write('Masukkan nama File Buku: '		 ); readln(filename); loadbook(filename, ptrbook);
			write('Masukkan nama File User: '		 ); readln(filename); loaduser(filename, ptruser);
			write('Masukkan nama File Peminjaman: '	 ); readln(filename); loadborrow(filename, ptrborrow);
			write('Masukkan nama File Pengembalian: '); readln(filename); loadreturn(filename, ptrreturn);
			write('Masukkan nama File Buku Hilang: ' ); readln(filename); loadmissing(filename, ptrmissing);
			writeln();
			write('File perpustakaan berhasil dimuat!');

			books 		:= ptrbook^;
			users 		:= ptruser^;
			borrows 	:= ptrborrow^;
			returns 	:= ptrreturn^;
			missings	:= ptrmissing^;
		end else begin
			writeln(notAdminMsg);
		end;
	end;

procedure saveAllFiles();
	{DESKRIPSI	: (F14) meminta input nama file dari user kemudian mengisi
			  	  file tsb dengan array yang bersangkutan}
	{I.S. 		: Sembarang}
	{F.S.		: Semua array of ADT tersimpan dalam file sesuai input dari user}
	{Proses 	: Meminta input nama file, lalu menyimpan array of ADT dalam file tsb}

	{KAMUS LOKAL}
	var
		filename	: string;

	{ALGORITMA}
	begin
		if (activeUser.username <> wraptext('Anonymous')) then begin
			books 		:= ptrbook^;
			users 		:= ptruser^;
			borrows 	:= ptrborrow^;
			returns 	:= ptrreturn^;
			missings 	:= ptrmissing^;

			write('Masukkan nama File Buku: '		 ); readln(filename); savebook(filename, ptrbook);
			write('Masukkan nama File User: '		 ); readln(filename); saveuser(filename, ptruser);
			write('Masukkan nama File Peminjaman: '	 ); readln(filename); saveborrow(filename, ptrborrow);
			write('Masukkan nama File Pengembalian: '); readln(filename); savereturn(filename, ptrreturn);
			write('Masukkan nama File Buku Hilang: ' ); readln(filename); savemissing(filename, ptrmissing);
			writeln();
			write('Data berhasil disimpan!');
		end else begin
			writeln(notLoggedInMsg);
		end;
	end;

procedure findUser();
	{DESKRIPSI	: (F15) mencari anggota dengan username sesuai input dari user}
	{I.S. 		: array of User terdefinisi}
	{F.S.		: nama dan alamat user yang dicari tertulis di layar}
	{Proses 	: Menanyakan pada user username siapa yang akan dicari, lalu mencari username dan alamat user tersebut
		          lalu menampilkannya di layar}

	{KAMUS LOKAL}
	var
		targetUsername 	: string;

	{ALGORITMA}
	begin
		if (activeUser.isAdmin) then begin
			write('Masukkan username: '); readln(targetUsername);
			findUserUtil(wraptext(targetUsername), ptruser);
		end else begin
			writeln(notAdminMsg);
		end;
	end;

procedure exitProgram();
	{DESKRIPSI	: (F16) prosedur dijalankan sekali, yaitu saat menerima query exit}
	{I.S. 		: array of ADT terdefinisi}
	{F.S.		: keluar dari program dan file data tersimpan dalam format csv}
	{Proses 	: Menanyakan pada user apakah ingin menyimpan file, lalu menyimpan file,
			  	  lalu keluar dari program}

	{KAMUS LOKAL}
	var
		wantSave: char;

	{ALGORITMA}
	begin
		clrscr_();
		writeln('$ exit');
		{Validasi Input}
		repeat
			writeln();
			writeln('Simpan data? (Y/N)');
			write('$ '); readln(wantSave);
		until ((wantSave = 'Y') or (wantSave = 'y') or (wantSave = 'N') or (wantSave = 'n'));
		writeln();

		{Save file sebelum program ditutup}
		if ((wantSave = 'Y') or (wantSave = 'y')) then begin
			writeln('$ save');
			saveAllFiles();
			writeln();
		end;

		write('Tekan ENTER untuk menutup program.'); readln();
		clrscr_();
	end;

procedure logout();
	{DESKRIPSI	: (T01) logout dari akun sekarang}
	{I.S. 		: sembarang (akan dilakukan validasi)}
	{F.S.		: activeUser menjadi default (anonymous)}
	{Proses 	: cek sudah login/belum, validasi input mau logout/tidak, set activeuser menjadi default}

	{KAMUS LOKAL}
	var
		wantLogout	: char;

	{ALGORITMA}
	begin
		if (activeUser.username <> wraptext('Anonymous')) then begin
			{Validasi Input}
			repeat
				writeln('Yakin? (Y/N)');
				write('$ '); readln(wantLogout);
			until ((wantLogout = 'Y') or (wantLogout = 'y') or (wantLogout = 'N') or (wantLogout = 'n'));
			writeln();

			{Save file sebelum program ditutup}
			if ((wantLogout = 'Y') or (wantLogout = 'y')) then begin
				clrscr_();
				writeln('$ logout');

				setToDefaultUser(ptractiveUser);
				activeUser := ptractiveUser^;

				writeln('Berhasil logout.'); 
				writeln('Selamat datang ', unwraptext(activeUser.fullname) , '!');
			end;
		end else begin
			writeln(notLoggedInMsg);
		end;
	end;

{ALGORITMA}
begin
	init();
	while (not (query = 'exit')) do begin
		clrscr_(); writeln('$ ', query);
		case query of
			'register'				: registerUser();
			'login' 				: login();
			'cari' 					: findBookByCategory();
			'caritahunterbit' 		: findBookByYear();
			'pinjam_buku' 			: borrowBook();
			'kembalikan_buku' 		: returnBook();
			'lapor_hilang'			: addMissingBook();
	        'lihat_laporan' 		: showMissings();
			'tambah_buku' 			: addNewBook();
			'tambah_jumlah_buku' 	: addBookQty();
			'riwayat' 				: showBorrowHistory();
			'statistik' 			: showStats();
			'load' 					: loadAllFiles();
			'save' 					: saveAllFiles();
			'cari_anggota' 			: findUser();
			'logout'				: logout();
		end;
		writeln();write('Tekan ENTER untuk melanjutkan.'); readln(); clrscr_();

		printFeatures(ptractiveUser);
		write('$ '); readln(query); writeln();
		while (not queryValid(query)) do begin
			writeln('Command tidak terdaftar! Silahkan ulangi lagi!');
			write('$ '); readln(query);
			writeln();
		end;
	end;

	{EXIT}
	exitProgram();
end.
