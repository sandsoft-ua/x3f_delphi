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

unit x3f_process;

interface

uses x3f_io;

type
  x3f_color_encoding_t = (
    NONE        = 0 {  Preprocessed but unconverted data  },
    SRGB        = 1 {  Preproccesed and convered to sRGB  },
    ARGB        = 2 {  Preproccesed and convered to Adobee RGB  },
    PPRGB       = 3 {  Preproccesed and convered to ProPhoto RGB  },
    UNPROCESSED = 4 {  RAW data without any preprocessing  },
    QTOP        = 5 {  Quattro top layer without any preprocessing  });

  x3f_image_levels = record
    black: array[0..2] of Double ;
    white: array[0..2] of uint32;
  end;
  Px3f_image_levels = ^x3f_image_levels;

var
  black: array[0..2] of Double;
  white: array[0..2] of Cardinal;

function x3f_get_image(_x3f: Px3f;
			       var image: x3f_area16;
			       ilevels: Px3f_image_levels;
			       encoding: x3f_color_encoding_t;
			       crop,
			       fix_bad,
			       denoise: Boolean;
			       apply_sgain: Integer;
			       wb: String): Boolean;

implementation

uses x3f_meta, x3f_image;

function x3f_get_image(_x3f: Px3f; var image: x3f_area16; ilevels: Px3f_image_levels;
  encoding: x3f_color_encoding_t; crop, fix_bad, denoise: Boolean;
  apply_sgain: Integer; wb: String): Boolean;
var
  original_image, expanded, _qtop: x3f_area16;
  il: x3f_image_levels;
begin
  if wb = '' then
    wb := x3f_get_wb(_x3f);

  if encoding = QTOP then
  begin
    if not x3f_image_area_qtop(_x3f, _qtop) then
      Exit(False);

{    if not crop or not x3f_crop_area_camf(_x3f, 'ActiveImageArea', _qtop, 0, image) then
      image := _qtop;
} //Not implemented yet!
    Exit(ilevels = nil);
  end;

  if not x3f_image_area(_x3f, original_image) then
    Exit(False);

  image := original_image;  //Test!!!
{
  if not crop or not
    x3f_crop_area_camf(_x3f, 'ActiveImageArea', original_image, 1, image) then
    image := original_image;

  if encoding = UNPROCESSED then
    Exit(ilevels = nil);
}
  if not preprocess_data(_x3f, fix_bad, wb, &il) then
    Exit(False);
{
  if (expand_quattro(_x3f, denoise, expanded)) then
  begin
    //* NOTE: expand_quattro destroys the data of original_image */
    if not crop or not x3f_crop_area_camf(_x3f, 'ActiveImageArea', expanded, 0, image) then
      image := expanded;

    original_image := expanded;
  end
  else
    if denoise and not run_denoising(_x3f) then
      Exit(False);

  if (encoding <> NONE) and
      not convert_data(_x3f, original_image, il, encoding, apply_sgain, wb) then
  begin
    FreeMem(image.buf);
    Exit(False);
  end;

  if Assigned(ilevels) then
    ilevels := il;
}
  Result := True;
end;

end.
