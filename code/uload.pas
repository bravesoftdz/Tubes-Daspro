unit uload;
{Membaca file-file csv yang dibutuhkan program utama dan memuatnya ke dalam array of ADT masing-masing, contoh: array of ADT Buku}
{REFERENSI	: http://wiki.freepascal.org/File_Handling_In_Pascal
			  https://www.youtube.com/watch?v=AOYbfHHh4bE (Reading & Writing to CSV Files in Pascal by Holly Billinghurst)}

interface
uses
	k03_kel3_utils, ucsvwrapper,
	ubook, uuser, udate;

{PUBLIC VARIABLE, CONST, ADT}
const
	LOAD_MAXWORD = 1000;

{PUBLIC FUNCTIONS, PROCEDURE}
procedure loadbook(filename: string; ptr: pbook);
procedure loaduser(filename: string; ptr: puser);
procedure loadborrow(filename: string; ptr: pborrow);
procedure loadreturn(filename: string; ptr: preturn);
procedure loadmissing(filename: string; ptr: pmissing);


implementation
{PRIVATE VARIABLE, CONST, ADT}
type
	{Definisi ADT input dari file}
	inputStream = array[1..LOAD_MAXWORD] of string;

	{pointer dari array inputStream}
	pinput = ^inputStream;

var
	wordcnt: integer;

{FUNGSI dan PROSEDUR}
procedure parserow(str: string; ptr: pinput);
	{DESKRIPSI	: Mencari cell yang memuat koma, kemudian mengubahnya menjadi string yang dapat digunakan pada program}
	{I.S. 		: sembarang}
	{F.S.		: string kompatibel dengan program dan dapat dimasukkan ke array of ADT}
	{Proses 	: mencari kombinasi char ' ,"x ' (menandakan awal cell yang dibungkus) dan
									char ' x", ' (menandakan akhir cell yang dibungkus) dengan
				  x karakter sembarang bukan quote ' " '
				  lalu membuka cell yang dibungkus, dan tidak mengubah cell yang tidak dibungkus}

	{KAMUS LOKAL}
	var
		i			: integer;
		wrappedtext : string;

	{ALGORITMA}
	begin
		i := 1;
		wordcnt += 1;
		ptr^[wordcnt] := '';
		while (i <= length(str)) do begin
			{cell dibungkus wrapper}
			if (((i = 1) or ((i - 1 >= 1) and (str[i - 1] = delimiter))) and
			    (str[i] = wrapper) and
			    ((i = length(str)) or ((i + 1 <= length(str)) and (str[i + 1] <> wrapper)))) then begin

				wrappedtext := '';
				repeat
					wrappedtext += str[i];
					i += 1;
				until (((i = 1) or ((i - 1 >= 1) and (str[i - 1] <> wrapper))) and
					   (str[i] = wrapper) and
					   ((i = length(str)) or ((i + 1 <= length(str)) and (str[i + 1] = delimiter))));

				wrappedtext += str[i];
				ptr^[wordcnt] := unwraptext(wrappedtext);

			{cell tidak dibungkus wrapper}
			end else begin
				if (str[i] = delimiter) then begin
					wordcnt += 1;
					ptr^[wordcnt] := '';
				end else begin
					ptr^[wordcnt] += str[i];
				end;
			end;
			i += 1;
		end;
	end;

function readInput(filename: string; delimiter: char): pinput;
	{DESKRIPSI	: membaca file teks dan memuat ke dalam array agar dapat digunakan program/unit lain}
	{PARAMETER 	: nama file (beserta extensionnya) dan karakter delimiter (pemisah masing-masing kolom), pada kasus ini (CSV), adalah koma ','}
	{RETURN 	: pointer dari ADT inputStream}

	{KAMUS LOKAL}
	var
		f 			: text;
		readline 	: string;
		filetext 	: inputStream;
		i 			: integer;
		ptr 		: pinput;

	{ALGORITMA}
	begin
		{KONSTRUKTOR, set isi array menjadi string '-', sebagai penanda
		end of file, sehingga dapat dihitung N-efektifnya}
		for i:= 1 to LOAD_MAXWORD do begin
			filetext[i] := '-';
		end;
		new(ptr);
		ptr^ := filetext;

		{memuat file ke variabel f}
		system.assign(f, filename);
		system.reset(f);

		{membaca isi file csv}
		wordcnt := 0;
		while not EOF(f) do begin {ulangi selama belum EOF/EndOfFile}
			readln(f, readline);
			parserow(readline, ptr);
		end;
		close(f);
		readInput := ptr;
	end;

procedure loadbook(filename: string; ptr: pbook);
	{DESKRIPSI	: Memuat file csv berisi data buku ke dalam ADT array of Book}
	{I.S. 		: pointer pbook terdefinisi, array tbook terdefinisi, filename ada di direktori}
	{F.S.		: array tbook terisi sesuai isi filename,}
	{Proses 	: meminta input nama file, lalu memisah masing-masing kolom menjadi beberapa type dari buku,
			  	  mengisi variabel bookNeff sesuai jumlah baris dari file csv}

	{KAMUS LOKAL}
	var
		ploadedcsv	: pinput;
		i, row 		: integer;
		column		: integer;

	{ALGORITMA}
	begin
		ploadedcsv 	:= readInput(filename, ',');
		column 		:= BOOK_COLUMN; {6}

		{memisah-misah file loadedcsv ke beberapa array}
		{row : counter indeks array yang sudah diolah}
		{i   : counter indeks array yang belum diolah}
		{menggunakan modulo karena kolom berulang setiap n data}
		i := column;
		row := (i div column) - 1;
		while not (ploadedcsv^[i + 1] = '-') do begin
			i += 1;
			if ((i mod column) = 1) then begin
				row += 1;
				ptr^[row].id 		:= StrToInt(ploadedcsv^[i]);
			end else if ((i mod column) = 2) then begin
				ptr^[row].title 	:= wraptext(ploadedcsv^[i]);
			end else if ((i mod column) = 3) then begin
				ptr^[row].author	:= wraptext(ploadedcsv^[i]);
			end else if ((i mod column) = 4) then begin
				ptr^[row].qty 		:= StrToInt(ploadedcsv^[i]);
			end else if ((i mod column) = 5) then begin
				ptr^[row].year 		:= StrToInt(ploadedcsv^[i]);
			end else if ((i mod column) = 0) then begin
				ptr^[row].category	:= ploadedcsv^[i];
			end;
		end;
		bookNeff := row;
	end;


procedure loaduser(filename: string; ptr: puser);
	{DESKRIPSI	: Memuat file csv berisi data buku ke dalam ADT array of User}
	{I.S. 		: pointer puser terdefinisi, array tuser terdefinisi, filename ada di direktori}
	{F.S.		: array tuser terisi sesuai isi filename,}
	{Proses 	: meminta input nama file, lalu memisah masing-masing kolom menjadi beberapa type dari user,
			  	  mengisi variabel userNeff sesuai jumlah baris dari file csv}

	{KAMUS LOKAL}
	var
		ploadedcsv	: pinput;
		i, row 		: integer;
		column 		: integer;

	{ALGORITMA}
	begin
		ploadedcsv 	:= readInput(filename, ',');
		column 		:= USER_COLUMN; {5}

		{memisah-misah file loadedcsv ke beberapa array}
		{row : counter indeks array yang sudah diolah}
		{i   : counter indeks array yang belum diolah}
		{menggunakan modulo karena kolom berulang setiap n data}
		i := column;
		row := (i div column) - 1;
		while not (ploadedcsv^[i + 1] = '-') do begin
			i += 1;
			if ((i mod column) = 1) then begin
				row += 1;
				ptr^[row].fullname 	:= wraptext(ploadedcsv^[i]);
			end else if ((i mod column) = 2) then begin
				ptr^[row].address 	:= wraptext(ploadedcsv^[i]);
			end else if ((i mod column) = 3) then begin
				ptr^[row].username 	:= wraptext(ploadedcsv^[i]);
			end else if ((i mod column) = 4) then begin
				ptr^[row].password 	:= ploadedcsv^[i];
			end else if ((i mod column) = 0) then begin
				ptr^[row].isAdmin 	:= ploadedcsv^[i] = 'Admin';
			end;
		end;
		userNeff := row;
	end;


procedure loadborrow(filename: string; ptr: pborrow);
	{DESKRIPSI	: Memuat file csv berisi data buku ke dalam ADT array of BorrowHistory}
	{I.S. 		: pointer pBorrowHistory terdefinisi, array tBorrowHistory terdefinisi, filename ada di direktori}
	{F.S.		: array tBorrowHistory terisi sesuai isi filename,}
	{Proses 	: meminta input nama file, lalu memisah masing-masing kolom menjadi beberapa type dari BorrowHistory,
			  	  mengisi variabel BorrowNeff sesuai jumlah baris dari file csv}

	{KAMUS LOKAL}
	var
		ploadedcsv	: pinput;
		i, row 		: integer;
		column 		: integer;

	{ALGORITMA}
	begin
		ploadedcsv 	:= readInput(filename, ',');
		column 		:= BORROW_COLUMN; {5}

		{memisah-misah file loadedcsv ke beberapa array}
		{row : counter indeks array yang sudah diolah}
		{i   : counter indeks array yang belum diolah}
		{menggunakan modulo karena kolom berulang setiap n data}
		i := column;
		row := (i div column) - 1;
		while not (ploadedcsv^[i + 1] = '-') do begin
			i += 1;
			if ((i mod column) = 1) then begin
				row += 1;
				ptr^[row].username 		:= wraptext(ploadedcsv^[i]);
			end else if ((i mod column) = 2) then begin
				ptr^[row].id 			:= StrToInt(ploadedcsv^[i]);
			end else if ((i mod column) = 3) then begin
				ptr^[row].borrowDate	:= StrToDate(ploadedcsv^[i]);
			end else if ((i mod column) = 4) then begin
				ptr^[row].returnDate 	:= StrToDate(ploadedcsv^[i]);
			end else if ((i mod column) = 0) then begin
				ptr^[row].isBorrowed 	:= ploadedcsv^[i] = 'belum';
			end;
		end;
		borrowNeff := row;
	end;


procedure loadreturn(filename: string; ptr: preturn);
	{DESKRIPSI	: Memuat file csv berisi data buku ke dalam ADT array of ReturnHistory}
	{I.S. 		: pointer pReturnHistory terdefinisi, array tReturnHistory terdefinisi, filename ada di direktori}
	{F.S.		: array tReturnHistory terisi sesuai isi filename,}
	{Proses 	: meminta input nama file, lalu memisah masing-masing kolom menjadi beberapa type dari ReturnHistory,
			  	  mengisi variabel ReturnNeff sesuai jumlah baris dari file csv}

	{KAMUS LOKAL}
	var
		ploadedcsv	: pinput;
		i, row		: integer;
		column 		: integer;

	{ALGORITMA}
	begin
		ploadedcsv 	:= readInput(filename, ',');
		column 		:= RETURN_COLUMN; {3}

		{memisah-misah file loadedcsv ke beberapa array}
		{row : counter indeks array yang sudah diolah}
		{i   : counter indeks array yang belum diolah}
		{menggunakan modulo karena kolom berulang setiap n data}
		i := column;
		row := (i div column) - 1;
		while not (ploadedcsv^[i + 1] = '-') do begin
			i += 1;
			if ((i mod column) = 1) then begin
				row += 1;
				ptr^[row].username 		:= wraptext(ploadedcsv^[i]);
			end else if ((i mod column) = 2) then begin
				ptr^[row].id 			:= StrToInt(ploadedcsv^[i]);
			end else if ((i mod column) = 0) then begin
				ptr^[row].returnDate	:= StrToDate(ploadedcsv^[i]);
			end;
		end;
		returnNeff := row;
	end;


procedure loadmissing(filename: string; ptr: pmissing);
	{DESKRIPSI	: Memuat file csv berisi data buku ke dalam ADT array of MissingBook}
	{I.S. 		: pointer pMissingBook terdefinisi, array tMissingBook terdefinisi, filename ada di direktori}
	{F.S.		: array tMissingBook terisi sesuai isi filename,}
	{Proses 	: meminta input nama file, lalu memisah masing-masing kolom menjadi beberapa type dari MissingBook,
			  	  mengisi variabel MissingNeff sesuai jumlah baris dari file csv}

	{KAMUS LOKAL}
	var
		ploadedcsv	: pinput;
		i, row		: integer;
		column 		: integer;

	{ALGORITMA}
	begin
		ploadedcsv 	:= readInput(filename, ',');
		column 		:= MISSING_COLUMN; {3}

		{memisah-misah file loadedcsv ke beberapa array}
		{row : counter indeks array yang sudah diolah}
		{i 	 : counter indeks array yang belum diolah}
		{menggunakan modulo karena kolom berulang setiap n data}
		i := column;
		row := (i div column) - 1;
		while not (ploadedcsv^[i + 1] = '-') do begin
			i += 1;
			if ((i mod column) = 1) then begin
				row += 1;
				ptr^[row].username 		:= wraptext(ploadedcsv^[i]);
			end else if ((i mod column) = 2) then begin
				ptr^[row].id 			:= StrToInt(ploadedcsv^[i]);
			end else if ((i mod column) = 0) then begin
				ptr^[row].reportDate	:= StrToDate(ploadedcsv^[i]);
			end;
		end;
		missingNeff := row;
	end;
end.
