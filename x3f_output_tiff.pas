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
  if x3f_get_image(_x3f, _image, nil, encoding, crop, fix_bad, denoise,
    apply_sgain, wb) then
  begin
    f_out := TTIFFGraphic.Create;
//    f_out.Width :=

    f_out.SaveToFile(outfilename);
  end;
end;

end.
