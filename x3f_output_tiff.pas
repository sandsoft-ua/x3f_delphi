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
					     compress: Integer): x3f_return;

implementation

uses GraphicEx;

function x3f_dump_raw_data_as_tiff(_x3f: Px3f; outfilename: String;
				       encoding: x3f_color_encoding_t;
				       crop: Boolean;
					     fix_bad: Boolean;
					     denoise: Boolean;
					     apply_sgain: Integer;
					     wb: String;
					     compress: Integer): x3f_return;
var
  f_out: TTIFFGraphic;
  _image: x3f_area16;
begin
  Result := X3F_INTERNAL_ERROR;

  if x3f_get_image(_x3f, _image, nil, encoding, crop, fix_bad, denoise,
    apply_sgain, wb) then
  begin
    f_out := TTIFFGraphic.Create;
//    f_out.Width :=

    f_out.SaveToFile(outfilename);
    Result := X3F_OK;
  end;
end;

end.
