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

unit x3f_output_dng;

interface

uses x3f_io;

function x3f_dump_raw_data_as_dng(_x3f: Px3f; outfilename: String;
					     fix_bad: Boolean;
					     denoise: Boolean;
					     apply_sgain: Integer;
					     wb: String;
					     compress: Integer): x3f_return;

implementation

function x3f_dump_raw_data_as_dng(_x3f: Px3f; outfilename: String;
  fix_bad: Boolean; denoise: Boolean; apply_sgain: Integer; wb: String;
  compress: Integer): x3f_return;
begin
  Result := X3F_OK; //Test
end;

end.
