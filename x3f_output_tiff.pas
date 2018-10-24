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

unit x3f_output_tiff;

interface

uses x3f_io, x3f_process;

function x3f_dump_raw_data_as_tiff(_x3f: Px3f; outfilename: String;
				       encoding: x3f_color_encoding_t;
				       crop: Boolean;
					     fix_bad: Boolean;
					     denoise: Boolean;
					     apply_sgain: Integer;
					     wb: String;
					     compress: Boolean): x3f_return;

implementation

uses hyieutils, SysUtils, Windows;

function x3f_dump_raw_data_as_tiff(_x3f: Px3f; outfilename: String;
				       encoding: x3f_color_encoding_t;
				       crop: Boolean;
					     fix_bad: Boolean;
					     denoise: Boolean;
					     apply_sgain: Integer;
					     wb: String;
					     compress: Boolean): x3f_return;
var
  f_out: TIEBitmap;
//  f_out: Integer;
  _image: x3f_area16;
  row: Integer;
  _data: System.PWord;
begin
  Result := X3F_INTERNAL_ERROR;

  if x3f_get_image(_x3f, _image, nil, encoding, crop, fix_bad, denoise,
    apply_sgain, wb) then
  begin
    f_out := TIEBitmap.Create(_image.columns, _image.rows, ie48RGB);

    _data := _image.data;
    for row := 0 to _image.rows - 1 do
    begin
      Move(_data^, f_out.ScanLine[row]^, _image.row_stride * 2);
      Inc(_data, _image.row_stride);
    end;

//    f_out.Write(outfilename);
    f_out.Write('c:\temp\raw_test_01.jpg');

{
    f_out := FileOpen(outfilename, GENERIC_WRITE);
    if f_out <= 0 then
      f_out := FileCreate(outfilename, GENERIC_WRITE);

    try
      //There was a bug in Kalpanika source! It wroten not used 28 bytes (header size) to output file.
      SysUtils.FileWrite(f_out, _image.data^, _image.rows * _image.row_stride * 2);
    finally
      FileClose(f_out);
    end;
}
    Result := X3F_OK;
  end;
end;

end.
