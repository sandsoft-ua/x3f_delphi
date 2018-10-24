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

unit x3f_dump;

interface

uses x3f_io, Classes;

function x3f_dump_raw_data(_x3f: Px3f; outfilename: String): x3f_return;
function x3f_dump_jpeg(_x3f: Px3f; outfilename: String): x3f_return; overload;
function x3f_dump_jpeg(_x3f: Px3f; AStream: TStream): x3f_return; overload;

implementation

uses SysUtils, Windows;

function x3f_dump_raw_data(_x3f: Px3f; outfilename: String): x3f_return;
var
  DE: Px3f_directory_entry;
  _data: Pointer;
  f_out: Integer;
begin
   DE := x3f_get_raw(_x3f);

  if DE = nil then
    Result := X3F_ARGUMENT_ERROR
  else
    begin
      _data := DE.header.data_subsection.image_data.data;

      if _data = nil then
        Result := X3F_INTERNAL_ERROR
      else
        begin
          f_out := FileOpen(outfilename, GENERIC_WRITE);
          if f_out <= 0 then
            f_out := FileCreate(outfilename, GENERIC_WRITE);

          if f_out = 0 then
            Result := X3F_OUTFILE_ERROR
          else
            try
              //There was a bug in Kalpanika source! It wroten not used 28 bytes (header size) to output file.
              FileWrite(f_out, _data^, {DE.input.size}DE.header.data_subsection.image_data.data_size);
            finally
              FileClose(f_out);
              Result := X3F_OK;
            end;
        end;
    end;
end;

function x3f_dump_jpeg(_x3f: Px3f; outfilename: String): x3f_return;
var
  DE: Px3f_directory_entry;
  _data: Pointer;
  f_out: Integer;
begin
  DE := x3f_get_thumb_jpeg(_x3f);

  if DE = nil then
    Result := X3F_ARGUMENT_ERROR
  else
    begin
      _data := DE.header.data_subsection.image_data.data;

      if _data = nil then
        Result := X3F_INTERNAL_ERROR
      else
        begin
          f_out := FileOpen(outfilename, GENERIC_WRITE);
          if f_out <= 0 then
            f_out := FileCreate(outfilename, GENERIC_WRITE);

          if f_out <= 0 then
            Result := X3F_OUTFILE_ERROR
          else
            try
              //There was a bug in Kalpanika source! It wroten not used 28 bytes (header size) to output file.
              FileWrite(f_out, _data^, {DE.input.size}DE.header.data_subsection.image_data.data_size);
            finally
              FileClose(f_out);
              Result := X3F_OK;
            end;
        end;
    end;
end;

function x3f_dump_jpeg(_x3f: Px3f; AStream: TStream): x3f_return;
var
  DE: Px3f_directory_entry;
  _data: Pointer;
  _pos: Int64;
begin
  DE := x3f_get_thumb_jpeg(_x3f);

  if (DE = nil) or not Assigned(AStream) then
    Result := X3F_ARGUMENT_ERROR
  else
    begin
      _data := DE.header.data_subsection.image_data.data;

      if _data = nil then
        Result := X3F_INTERNAL_ERROR
      else
        begin
          _pos := AStream.Position;
          //There was a bug in Kalpanika source! It wroten not used 28 bytes (header size) to output file.
          AStream.Write(_data^, {DE.input.size}DE.header.data_subsection.image_data.data_size);
          AStream.Position := _pos;

          Result := X3F_OK;
        end;
    end;
end;

end.
