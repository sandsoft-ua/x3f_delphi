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

end;

end.
