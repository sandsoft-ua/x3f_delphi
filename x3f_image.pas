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

unit x3f_image;

interface

uses x3f_io;

function x3f_image_area(_x3f: Px3f; var image: x3f_area16): Boolean;
function x3f_image_area_qtop(_x3f: Px3f; var image: x3f_area16): Boolean;

implementation

function x3f_image_area(_x3f: Px3f; var image: x3f_area16): Boolean;
var
  DE: Px3f_directory_entry;
  DEH: Px3f_directory_entry_header;
  ID: Px3f_image_data;
  HUF: Px3f_huffman;
  TRU: Px3f_true_t;
  area: Px3f_area16;
begin
  Result := False;
  area := nil;
  DE := x3f_get_raw(_x3f);

  if Assigned(DE) then
  begin
    DEH := @(DE.header);
    ID := @(DEH.data_subsection.image_data);
    HUF := ID.huffman;
    TRU := ID.tru;

    if Assigned(HUF) then
      area := @(HUF.x3rgb16);

    if Assigned(TRU) then
      area := @(TRU.x3rgb16);

    if Assigned(area) and Assigned(area.data) then
    begin
      image := area^;
      image.buf := nil;		//* cleanup_true/cleanup_huffman is responsible for free() */

      Result := True;
    end;
  end;
end;

function x3f_image_area_qtop(_x3f: Px3f; var image: x3f_area16): Boolean;
var
  DE: Px3f_directory_entry;
  DEH: Px3f_directory_entry_header;
  ID: Px3f_image_data;
  Q: Px3f_quattro;
begin
  Result := False;

  DE := x3f_get_raw(_x3f);

  if Assigned(DE) then
  begin
    DEH := @(DE.header);
    ID := @(DEH.data_subsection.image_data);
    Q := ID.quattro;

    if Assigned(Q) and Assigned(Q.top16.data) then
    begin
      image := Q.top16;
      image.buf := nil;		//* cleanup_quattro is responsible for free() */

      Result := True;
    end;
  end;
end;

end.
