{********************************************************}
{*                  X3F Delphi Project                  *}
{*    Sigma RAW files to DNG, TIFF, JPEG conversion     *}
{*      Based on C sources from project Kalpanika       *}
{*           (https://github.com/Kalpanika)             *}
{*      Copyright SANDSoft Virtual Firm (c) 2018        *}
{*                                                      *}
{*      Last sources can be found at:                   *}
{*      https://github.com/sandsoft-ua/x3f_delphi       *}
{********************************************************}

//* Test program

program x3f_extract;

{$APPTYPE CONSOLE}

uses
  Windows,
  Types,
  SysUtils,
  x3f_process in 'x3f_process.pas',
  x3f_io in 'x3f_io.pas',
  x3f_output_dng in 'x3f_output_dng.pas',
  x3f_output_tiff in 'x3f_output_tiff.pas',
  x3f_meta in 'x3f_meta.pas',
  x3f_image in 'x3f_image.pas',
  x3f_dump in 'x3f_dump.pas';

type
  output_file_type_t = (
    META      = 0,
    JPEG      = 1,
    RAW       = 2,
    TIFF      = 3,
    DNG       = 4,
    PPMP3     = 5,
    PPMP6     = 6,
    HISTOGRAM = 7);

const // 1d arrays
  extension : array[output_file_type_t] of String = (
    '.meta',
    '.jpg',
    '.raw',
    '.tif',
    '.dng',
    '.ppm',
    '.ppm',
    '.csv' );


procedure usage(const progname: String);
begin
  Writeln(Format(
          'usage: %s <SWITCHES> <file1> ...' + sLineBreak +
          '   -o <DIR>        Use <DIR> as output directory' + sLineBreak +
          '   -v              Verbose output for debugging' + sLineBreak +
          '   -q              Suppress all messages except errors' + sLineBreak +
          'ONE OFF THE FORMAT SWITCHWES' + sLineBreak +
          '   -meta           Dump metadata' + sLineBreak +
          '   -jpg            Dump embedded JPEG' + sLineBreak +
          '   -raw            Dump RAW area undecoded' + sLineBreak +
          '   -tiff           Dump RAW/color as 3x16 bit TIFF' + sLineBreak +
          '   -dng            Dump RAW as DNG LinearRaw (default)' + sLineBreak +
          '   -ppm-ascii      Dump RAW/color as 3x16 bit PPM/P3 (ascii)' + sLineBreak +
          '                   NOTE: 16 bit PPM/P3 is not generally supported' + sLineBreak +
          '   -ppm            Dump RAW/color as 3x16 bit PPM/P6 (binary)' + sLineBreak +
          '   -histogram      Dump histogram as csv file' + sLineBreak +
          '   -loghist        Dump histogram as csv file, with log exposure' + sLineBreak +
          'APPROPRIATE COMBINATIONS OF MODIFIER SWITCHES' + sLineBreak +
          '   -color <COLOR>  Convert to RGB color space' + sLineBreak +
          '                   (none, sRGB, AdobeRGB, ProPhotoRGB)' + sLineBreak +
          '                   ''none'' means neither scaling, applying gamma' + sLineBreak +
          '                   nor converting color space.' + sLineBreak +
          '                   This switch does not affect DNG output' + sLineBreak +
          '   -unprocessed    Dump RAW without any preprocessing' + sLineBreak +
          '   -qtop           Dump Quattro top layer without preprocessing' + sLineBreak +
          '   -no-crop        Do not crop to active area' + sLineBreak +
          '   -no-denoise     Do not denoise RAW data' + sLineBreak +
          '   -no-sgain       Do not apply spatial gain (color compensation)' + sLineBreak +
          '   -no-fix-bad     Do not fix bad pixels' + sLineBreak +
          '   -sgain          Apply spatial gain (default except for Quattro)' + sLineBreak +
          '   -wb <WB>        Select white balance preset' + sLineBreak +
          '   -compress       Enable ZIP compression for DNG and TIFF output' + sLineBreak +
          '   -ocl            Use OpenCL' + sLineBreak +
          sLineBreak +
          'STRANGE STUFF' + sLineBreak +
          '   -offset <OFF>   Offset for SD14 and older' + sLineBreak +
          '                   NOTE: If not given, then offset is automatic' + sLineBreak +
          '   -matrixmax <M>  Max num matrix elements in metadata (def=100)',
          [progname]));
end;

function check_dir(var Path : String): integer;
begin
  if not DirectoryExists(Path) then
    Result := -1
  else
    Result := 0;
end;

function safecpy(var dst: String; const src: String; dst_size: integer): integer;
begin
  if Length(src) > dst_size then
  begin
//    x3f_printf(DEBUG, 'safecpy: String too large' + sLineBreak);  //!!!
    Result := 1;
  end
  else
    begin
      dst := Copy(src, 1, dst_size);
      Result := 0;
    end;
end;

function safecat(var dst: String; const src: String; dst_size: integer): integer;
begin
  if (Length(dst) + Length(src)) > dst_size then
  begin
//    x3f_printf(DEBUG, 'safecat: String too large'); //!!!
    Result := 1;
  end
  else
    begin
      dst := Concat(dst, src);
      Result := 0;
    end;
end;

const
  pathseps = '\:';

function make_paths(inpath, outdir, ext: String; var tmppath, outpath: String): integer;
var
  err, i : integer;
  p, _ptr: PChar;
begin
  err := 0;

  if outdir <> '' then
  begin
    _ptr := @inpath[1];
    for i := 1 to Length(pathseps) do
    begin
      p := StrRScan(@inpath[1], pathseps[i]);
      if Assigned(p) and ((p + 1) > _ptr) then
        _ptr := p + 1;
    end;

    err := err + safecpy(outpath, outdir, MAX_PATH);
    if Pos(outdir[Length(outdir)], pathseps) <= 0 then
      err := err + safecat(outpath, PathSep, MAX_PATH);

    err := err + safecat(outpath, _ptr, MAX_PATH);
  end
  else
    err := err + safecpy(outpath, inpath, MAX_PATH);

  err := err + safecat(outpath, ext, MAX_PATH);
  err := err + safecpy(tmppath, outpath, MAX_PATH);
  err := err + safecat(tmppath, '.tmp', MAX_PATH);

  Result := err;
end;


function Main: integer;
label
  clean_up, found_error;
var
  crop,
  denoise,
  fix_bad,
  extract_jpg,
  extract_raw,
  extract_unconverted_raw,
  extract_meta: Boolean; // Always computed
  apply_sgain,
  sgain,
  max_printed_matrix_elements,
  f_in: Integer;

  file_type: output_file_type_t;
  color_encoding: x3f_color_encoding_t;
  _x3f: Px3f;
  DE: Px3f_directory_entry;
  files,
  errors,
  log_hist,
  legacy_offset: Integer;
  wb: String;

  use_opencl: Integer;
  outdir, tmpfile, outfile: String;

  ret_dump, ret: x3f_return;

  i, j: Integer;
  encoding,
  infile: String;
  compress, auto_legacy_offset: Boolean;
begin
  extract_jpg := False;
  extract_raw := True;
  extract_unconverted_raw := False;
  crop := True;
  fix_bad := True;
  denoise := True;
  apply_sgain := -1;
  legacy_offset := 0;
  auto_legacy_offset := True;
  max_printed_matrix_elements := 0;

  file_type := DNG;
  color_encoding := SRGB;

  files := 0;
  errors := 0;
  log_hist := 0;
  wb := EmptyStr;
  compress := False;
  use_opencl := 0;
  outdir := EmptyStr;

  Writeln(Format('X3F TOOLS VERSION = %s' + sLineBreak, ['0.1gamma'{version}]));  //!!!

  { Set stdout and stderr to line buffered mode to avoid scrambling }
//  setvbuf(stdout, nil, _IOLBF, 0);  //!!! ???
//  setvbuf(stderr, nil, _IOLBF, 0);  //!!! ???

  for i := 1 to ParamCount - 1 do
  begin
    { Only one of those switches is valid, the last one }
    if  SameText(ParamStr(i), '-jpg') then
    begin
      extract_raw := False;
      extract_unconverted_raw := False;
      extract_jpg := True;
      file_type := JPEG;
    end
    else
    if SameText(ParamStr(i), '-meta') then
    begin
      extract_jpg := False;
      extract_raw := False;
      extract_unconverted_raw := False;
      file_type := META;
    end
    else
    if SameText(ParamStr(i), '-raw') then
    begin
      extract_jpg := False;
      extract_raw := False;
      extract_unconverted_raw := True;
      file_type := RAW;
    end
    else
    if SameText(ParamStr(i), '-tiff') then
    begin
      extract_jpg := False;
      extract_unconverted_raw := False;
      extract_raw := True;
      file_type := TIFF;
    end
    else
    if SameText(ParamStr(i), '-dng') then
    begin
      extract_jpg := False;
      extract_unconverted_raw := False;
      extract_raw := True;
      file_type := DNG;
    end
    else
    if SameText(ParamStr(i), '-ppm-ascii') then
    begin
      extract_jpg := False;
      extract_unconverted_raw := False;
      extract_raw := True;
      file_type := PPMP3;
    end
    else
    if SameText(ParamStr(i), '-ppm') then
    begin
      extract_jpg := False;
      extract_unconverted_raw := False;
      extract_raw := True;
      file_type := PPMP6;
    end
    else
    if SameText(ParamStr(i), '-histogram') then
    begin
      extract_jpg := False;
      extract_raw := True;
      extract_unconverted_raw := False;
      file_type := HISTOGRAM;
    end
    else
    if SameText(ParamStr(i), '-loghist') then
    begin
      extract_jpg := False;
      extract_raw := True;
      extract_unconverted_raw := False;
      file_type := HISTOGRAM;
      log_hist := 1;
    end
    else
    if SameText(ParamStr(i), '-color') and ((i + 1) < ParamCount) then
    begin
      encoding := ParamStr(i + 1);
      if  SameText(encoding, 'none') then
        color_encoding := NONE
      else
        if SameText(encoding, 'sRGB') then
          color_encoding := SRGB
        else
          if SameText(encoding, 'AdobeRGB') then
            color_encoding := ARGB
          else
            if SameText(encoding, 'ProPhotoRGB') then
              color_encoding := PPRGB
            else
              begin
                WriteLn(Format('Unknown color encoding: %s',[encoding]));
                usage(ExtractFileName(ParamStr(0)));
              end;

      continue;
    end
    else
    if SameText(ParamStr(i), '-o')  and ((i + 1) < ParamCount) then
    begin
      outdir := ParamStr(i + 1);
      continue;
    end
    else
    if SameText(ParamStr(i), '-v') then
//      x3f_printf_level := DEBUG //!!!
    else
    if SameText(ParamStr(i), '-q') then
//      x3f_printf_level := ERR //!!!
    else
    if SameText(ParamStr(i), '-unprocessed') then
      color_encoding := UNPROCESSED
    else
    if SameText(ParamStr(i), '-qtop') then
      color_encoding := QTOP
    else
    if SameText(ParamStr(i), '-no-crop') then
      crop := False
    else
    if SameText(ParamStr(i), '-no-fix-bad') then
      fix_bad := False
    else
    if SameText(ParamStr(i), '-no-denoise') then
      denoise := False
    else
    if SameText(ParamStr(i), '-no-sgain') then
      apply_sgain := 0
    else
    if SameText(ParamStr(i), '-sgain') then
      apply_sgain := 1
    else
    if SameText(ParamStr(i), '-wb') and ((i + 1) < ParamCount) then
    begin
      wb := ParamStr(i + 1);
      continue;
    end
    else
    if SameText(ParamStr(i), '-compress') then
      compress := True
    else
    if SameText(ParamStr(i), '-ocl') then
      use_opencl := 1
  { Strange Stuff }
    else
    if SameText(ParamStr(i), '-offset') and ((i + 1) < ParamCount) then
    begin
      legacy_offset := StrToInt(ParamStr(i + 1));
      auto_legacy_offset := False;
      continue;
    end
    else
    if SameText(ParamStr(i), '-matrixmax') and ((i + 1) < ParamCount) then
    begin
      max_printed_matrix_elements := StrToInt(ParamStr(i + 1));
      continue;
    end
    else
    if not SameText(ParamStr(i)[1], '-') then
      usage(ExtractFileName(ParamStr(0)))
    else
      break;      { Here starts list of files }
  end;

  if not outdir.IsEmpty and (check_dir(outdir) <> 0) then
  begin
    Writeln(Format('Could not find outdir %s', [outdir]));
    usage(ExtractFileName(ParamStr(0)));
  end;

//  x3f_set_use_opencl(use_opencl); //!!!

  extract_meta := (file_type = META) or (file_type = DNG) or
    (extract_raw and (crop or (color_encoding <> UNPROCESSED) and (color_encoding <> QTOP)));

  for j := i{ + 1} to ParamCount do
  begin
    infile := ParamStr(j);
    f_in := FileOpen(infile, GENERIC_READ);
    _x3f := nil;
    Inc(files);

    if f_in = 0 then
    begin
      Writeln(Format('Could not open infile %s', [infile]));
      goto found_error;
    end;

    Writeln(Format('READ THE X3F FILE %s', [infile]));

    _x3f := x3f_new_from_file(f_in);
    if not Assigned(_x3f) then
    begin
      Writeln(Format('Could not read infile %s', [infile]));
      goto found_error;
    end;

    if extract_jpg then
    begin
      ret := x3f_load_data(_x3f, x3f_get_thumb_jpeg(_x3f));
      if ret <> X3F_OK then
      begin
        Writeln(Format('Could not load JPEG thumbnail from %s (%s)',  [infile, x3f_err(ret)]));
        goto found_error;
      end;
    end;

    if extract_meta then
    begin
(*      DE := x3f_get_prop(x3f);  //!!!

      ret := x3f_load_data(x3f, x3f_get_camf(x3f then ));
      if ret <> X3F_OK then
      begin
        Writeln(Format('Could not load CAMF from %s (%s)', [infile, x3f_err(ret))]);
        goto found_error;
      end;

      if Assigned(DE) then { Not for Quattro }
      begin
        ret := x3f_load_data(x3f, DE);
        if ret <> X3F_OK then
        begin
          Writeln(Format('Could not load PROP from %s (%s)', [infile, x3f_err(ret)]));
          goto found_error;
        end;
      end;*) //!!!
      { We do not load any JPEG meta data }
    end;

    if extract_raw then
    begin
      DE := x3f_get_raw(_x3f);

      if not Assigned(DE) then
      begin
        Writeln({ERR, }'Could not find any matching RAW format');
        goto found_error;
      end;

      ret := x3f_load_data(_x3f, DE);

      if ret <> X3F_OK then
      begin
//        Writeln(Format('Could not load RAW from %s (%s)', [infile, x3f_err(ret)]));
        goto found_error;
      end;
    end;

    if extract_unconverted_raw then
    begin
      DE := x3f_get_raw(_x3f);
      if not Assigned(DE) then
      begin
        Writeln('Could not find any matching RAW format');
        goto found_error;
      end;

      ret := x3f_load_image_block(_x3f, DE);
      if ret <> X3F_OK then
      begin
        Writeln(Format('Could not load unconverted RAW from %s (%s)', [infile, x3f_err(ret)]));
        goto found_error;
      end;
    end;

    if make_paths(infile, outdir, extension[file_type], tmpfile, outfile) <> 0 then
    begin
      Writeln(Format('Too large outfile path for infile %s and outdir %s', [infile, outdir]));
      goto found_error;
    end;

//    unlink(tmpfile);  //!!!
    { TODO: Quattro files seem to be already corrected for spatial
       gain. Is that assumption correct? Applying it only worsens the
       result anyhow, so it is disabled by default. }

    if apply_sgain = -1 then
      sgain := Integer(_x3f.header.version < X3F_VERSION_4_0)
    else
      sgain := apply_sgain;

    case file_type of
    META:
      begin
        Writeln(Format('Dump META DATA to %s', [outfile]));
//        ret_dump := x3f_dump_meta_data(x3f, tmpfile); //!!!
      end;
    JPEG:
      begin
        Writeln(Format('Dump JPEG to %s', [outfile]));
        ret_dump := x3f_dump_jpeg(_x3f, outfile);
      end;
    RAW:
      begin
        Writeln(Format('Dump RAW block to %s', [outfile]));
        ret_dump := x3f_dump_raw_data(_x3f, outfile);
      end;
    TIFF:
      begin
        Writeln(Format('Dump RAW as TIFF to %s', [outfile]));
        ret_dump := x3f_dump_raw_data_as_tiff(_x3f, {tmpfile}outfile, color_encoding,
          crop, fix_bad, denoise, sgain, wb, compress);
      end;
    DNG:
      begin
        Writeln(Format('Dump RAW as DNG to %s', [outfile]));
        ret_dump := x3f_dump_raw_data_as_dng(_x3f, tmpfile, fix_bad, denoise,
          sgain, wb, compress);
      end;
    PPMP3, PPMP6:
      begin
        Writeln(Format('Dump RAW as PPM to %s', [outfile]));
{        ret_dump := x3f_dump_raw_data_as_ppm(x3f, tmpfile,
              color_encoding,
              crop, fix_bad, denoise, sgain, wb,
              file_type := PPMP6);} //!!!
      end;
    HISTOGRAM:
      begin
        Writeln(Format('Dump RAW as CSV histogram to %s', [outfile]));
{        ret_dump := x3f_dump_raw_data_as_histogram(x3f, tmpfile,
              color_encoding,
              crop, fix_bad, denoise, sgain, wb,
              log_hist);} //!!!
      end;
    end;

{    if X3F_OK <> ret_dump then
    begin
      Writeln(Format('Could not dump to %s: %s',[ tmpfile, x3f_err(ret_dump)]));
      Inc(errors);
    end
    else
      begin
        if not RenameFile(tmpfile, outfile) then
        begin
          Writeln(Format('Could not rename %s to %s', [tmpfile, outfile]));
          Inc(errors);
        end;
    end;}
    goto clean_up;

  found_error:
    Inc(errors);

  clean_up:
    begin
//      x3f_delete(x3f);  //!!!
      if f_in <> 0 then
        FileClose(f_in);
    end;
  end;
  if files = 0 then
  begin
    Writeln('No files given');
    usage(ExtractFileName(ParamStr(0)));
    Exit;
  end;

  Writeln(Format('Files processed: %d errors: %d', [files, errors]));
  Result := errors;
end;

begin
  try
    Main;
  except
    on e:Exception do
      WriteLn(e.Message);
  end;
end.
